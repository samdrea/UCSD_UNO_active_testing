%% Program to acquire transmission spectra vs. heater tuning
% See details about data structure storing result in "save results" section
% Program can be safely run in full or in sections
%% %% Initialize Connections to Laser and Power Supply %% %%
delete (instrfindall); % Delete all existing instruments
laser = start_LMS(); % Initialize and connect laser
key = key_start(); % Initialize and connect keithley

%% %% Acquisition Settings %% %%
% Laser source settings
lambda_start = 1550; % nm, minimum 1454
lambda_end = 1600; % nm, maximum 1641
lambda_step = 1; % nm
lambda_speed = 10; % sweep speed in nm/s
laser_power = 0;  % dBm, min -10 and max 13 (output 2)

% Optical power meter settings
range = 0; % dB, will be rounded to nearest 10

% Power supply settings
% switch beetween V source (w/ I compliance) and I source (w/ V compliance)
use_current_priority = true;
% time to wait after changing power supply prior to acquiring spectrum
heater_settle_time = 1; % seconds

% V sweep settings (only used if use_current_priority is false!)
V_start = 0; % volts
V_end = 10; % volts
V_step = 1; % volts
I_compliance = 10; % mA

% I sweep settings (only used if use_current_priority is true!)
I_start = 0; % mA
I_end = 50; % mA
I_step = 10; % mA
V_compliance = 10; % volts

%% %% Run Acquisition %% %%

% generate basic matricies from settings + setup power supply
lambda_list = lambda_start:lambda_step:lambda_end;
if(use_current_priority) 
    I_list = I_start:I_step:I_end;
    heater_points = length(I_list);
    V_list = zeros(length(I_list), 1);
    key_config_I_source(key, V_compliance);
else
    V_list = V_start:V_step:V_end;
    heater_points = length(V_list);
    I_list = zeros(length(V_list), 1);
    key_config_V_source(key, I_compliance);
end
I_list_actual = zeros(heater_points, 1);
V_list_actual = zeros(heater_points, 1);
P_list_actual = zeros(heater_points, 1);
spectra_results = [];

% reset Keithley output to 0 prior to turning on
% this is generally redundant but is safe to prevent exposing circuit to
% ... unexpected voltage/current
if(use_current_priority)
    key_set_I(key, 0);
else 
    key_set_V(key, 0);
end
% Turn on Keithley outside loop so tuning inside loop will be more stable
% (turning on/off after every spectrum might delay thermal equilibrium)
key_output(key, true)
% Loop over power supply steps and acquire spectrum at each one
for heater_index=1:heater_points
    % Set Keithley to proper voltage/current setting
    if(use_current_priority)
        disp("Setting Keithley current: " + num2str(I_list(heater_index)));
        key_set_I(key, I_list(heater_index));
    else 
        disp("Setting Keithley voltage: " + num2str(V_list(heater_index)));
        key_set_V(key, V_list(heater_index));
    end
    
    if(heater_settle_time)
        disp("Allowing heater to settle...");
        pause(heater_settle_time)
    end
    
    disp("Acquiring spectrum (" + num2str(heater_index) + " of " + num2str(heater_points));
    % Read actual voltage and current for each measurement
    [voltage, current] = key_measure(key);
    I_list_actual(heater_index) = current;
    V_list_actual(heater_index) = voltage;
    % Calculate actual power from these and add to list
    P_list_actual(heater_index) = voltage*current;
    % Aquire spectrum using 8164b
    N = LMS_set_param(laser,lambda_speed,lambda_step,laser_power,lambda_start,lambda_end,range);
    [x1,y1] = laser_scan(laser,N);
    % Add to output data structure
    spectra_results = cat(3, spectra_results, [x1;y1]);
end
% Turn off power supply once finished
key_output(key, false)
%% %% Save Result %% %%
% Saves all variables into .mat file (locat. picked using GUI)
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end

%% %% Plot Result %% %%
% plots all spectra on one plot with blue-to-red color coding
laser_power_mW = 10^(laser_power/10);
figure;
hold on
for i = 1:size(spectra_results,3)
    if(use_current_priority)
        name = num2str(I_list_actual(i)) + " mA";
    else
        name = num2str(V_list_actual(i)) + " V";
    end
    color = getColor(i,size(spectra_results,3));
    plot(spectra_results(1,:,i),10*log10(spectra_results(2,:,i)./laser_power_mW),...
        "DisplayName", name, ...
        "Color", getColor(i,size(spectra_results,3)), ...
        "LineWidth", 2);
end
hold off;
legend();
xlabel("Wavelength");
ylabel("Insertion loss (dB)");

function color = getColor(index, size)
    % simple blue-to-red LUT
    startHue = 0.7;
    endHue = 1;
    startVal = 0.7;
    endVal = 1;
    hue = startHue + (index-1)*(endHue-startHue)/(size-1);
    val = startVal + (index-1)*(endVal-startVal)/(size-1);
    color = hsv2rgb(hue,1,val);
end