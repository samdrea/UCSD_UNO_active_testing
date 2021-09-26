%% Program to sweep heaters and record transmission at single wavelength
%% %% Initialize Connections to Laser and Power Supply %% %%
delete (instrfindall); % Delete all existing instruments
laser = start_LMS(); % Initialize and connect laser
key = key_start(); % Initialize and connect keithley
%% %% Acquisition Settings %% %%
% Laser source settings
lambda = 1460; % nm, minimum 1460, maximum 1600
laser_power = 0;  %dbm, min TODO and max TODO (on output 2)

% Optical power meter settings can be changed on laser module

% Power supply settings
% switch beetween V source (w/ I compliance) and I source (w/ V compliance)
use_current_priority = false;
% time to wait after changing power supply prior to acquiring spectrum
heater_settle_time = 0; % seconds; set to 0 for no pause

% V sweep settings (only used if use_current_priority is false!)
V_start = 0; % volts
V_end = 10; % volts
V_step = 1; % volts
I_compliance = 80; % mA

% I sweep settings (only used if use_current_priority is true!)
I_start = 0; % mA
I_end = 50; % mA
I_step = 10; % mA
V_compliance = 10; % volts

%% %% Run Acquisition %% %%
% generate basic matricies from settings + setup power supply
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
transmission_results = zeros(heater_points, 1);

% set laser params
laser_set_basic_params(laser, laser_power, lambda);

% reset Keithley output to 0 prior to turning on
% this is generally redundant but is safe to prevent exposing circuit to
% ... unexpected voltage/current
if(use_current_priority)
    key_set_I(key, 0);
else 
    key_set_V(key, 0);
end
% turn on laser and power supply
key_output(key, true)
laser_output(laser, true)
for heater_index = 1:heater_points 
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
    
    % Read actual voltage and current for each measurement
    [voltage, current] = key_measure(key);
    I_list_actual(heater_index) = current;
    V_list_actual(heater_index) = voltage;
    % Calculate actual power from these and add to list
    P_list_actual(heater_index) = voltage*current;
    % Grab power meter reading from 8164b
    transmission_results(heater_index) = laser_get_power(laser);
end
% turn off laser and power supply
key_output(key, false)
laser_output(laser, false)
%% %% Save Result %% %%
% Saves all variables into .mat file (locat. picked using GUI)
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end

%% %% Plot Result %% %%
laser_power_mW = 10^(laser_power/10);
plot(P_list_actual, 10*log10(transmission_results./laser_power_mW));
xlabel("Power (mW)");
ylabel("Transmission (dB)");
