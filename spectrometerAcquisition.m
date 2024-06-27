% single wavelength sweep where we change two heaters at the same time 
% for now, just writing code specially for one of these being keithley and
% one of these being keysight
clear;
delete (instrfindall); % Delete all existing instruments
agi = start_laser(); % Initialize and connect Agilent power meter
%ven = venturi_connect();
key = key_start(); % Initialize and connect keithley
kes = kes_start();
%% Check that things are in contact
kes_set_4wire(kes, false);
kes_config_I_source(kes, 10);
kes_set_I(kes, 1);
kes_measure_resistance(kes)
key_set_4wire(key, false);
fwrite(key, 'sens:res:mode MAN');
key_config_I_source(key, 10);
key_set_I(key, 1);
key_measure_resistance(key)

%% %% Acquisition Settings %% %%
% time to wait after changing power supply prior to taking measurements
settle_time = 0;% .5; % seconds

P_start = 0; % mW
P_end = 2001; % mW
P_step = 3; % mW
P_list_increasing = 0:P_step:P_end;
P_list_decreasing = P_end:-P_step:0;
% assign power lists to instruments
% "forward"
kes_power_list = P_list_increasing;
key_power_list = P_list_decreasing;
% "backward"
% kes_power_list = zeros(size(P_list_decreasing));
% key_power_list = P_list_increasing;

% complaince settings - power supplies never exceed either of these
I_compliance = 70; % mA
V_compliance = 75; % volts

start_pause_time = 15;
%% %% Run Acquisition %% %%
% Configure power supplies as voltage sources with the provided compliance
kes_config_V_source(kes, I_compliance);
key_config_V_source(key, I_compliance);
% set output to nonzero on the keysight as and otherwise you get a bogus
% reading (I use 1 volts, it could be anything)
% kes_set_V(kes,1);
% key_measure_resistance(key);
% kes_measure_resistance(kes);
% pause(1); % just flash these up for visual check that we're still connected
% 4-port R's (kohm): corner heater has 14.1931, other heater has 14.455
% key_resistance = 14.455e3; % manually measured 4-port heater resistance
% kes_resistance = 14.1931e3;
key_resistance = 928.6; % approximate resistances of the two heaters
kes_resistance = 928.2;
% key_resistance = 727; % approximate resistances of the two heaters
% kes_resistance = 727;
%kes_resistance = kes_measure_resistance(kes);
% units: V = sqrt(ohm*W) -> V = sqrt(ohm*mW/1000)
% units: I [A] = sqrt(P [W]/R [ohm]) -> I [mA] = sqrt(1000 * P [mW] / R [ohm])
key_current_list = sqrt(1000*(key_power_list/key_resistance));
kes_current_list = sqrt(1000*(kes_power_list/kes_resistance));
% 
sweep_number = length(key_current_list); 
if(length(kes_current_list) ~= length(key_current_list))
    error("Keithley and Keysight voltage lists are not the same length");
end
% safety warnings
key_max_current = max(key_current_list);
key_est_max_voltage = 1e-3*key_resistance*key_max_current;
disp(['Measured Keithley resistance (ohm): ' num2str(key_resistance,4)]);
if(key_resistance > 1e6)
    error('Keithley Load resistance greater than 1 Mohm, likely open circuit.');
end 
disp(['Max Keithley current to be applied: ' num2str(key_max_current,4)]);
if(key_max_current > I_compliance)
    warning("Specified power sweep will exceed compliance current on Keithley!");
    disp(['Compliance current: ' num2str(I_compliance,4)]);
    disp('If you continue, the output (and therefore the power) will be limited by the compliance current.');
    response = input('Continue (y/n)','s');
    if(response ~= 'y')
        return
    end 
end
disp(['Estimated max Keithley voltage (V): ' num2str(key_est_max_voltage,4)]);
if((key_est_max_voltage) > V_compliance)
    warning("Specified power sweep might exceed compliance voltage!");
    disp(['Compliance voltage: ' num2str(V_compliance)]);
    disp('If you continue, the output (and therefore the power) will be limited by the compliance voltage.');
    response = input('Continue (y/n)','s');
    if(response ~= 'y')
        return
    end
end

kes_max_current = max(kes_current_list);
kes_est_max_voltage = 1e-3*kes_max_current*kes_resistance;
disp(['Measured Keysight resistance (ohm): ' num2str(kes_resistance,4)]);
if(kes_resistance > 1e6)
    error('Keysight Load resistance greater than 1 Mohm, likely open circuit.');
end 
disp(['Max Keysight current to be applied: ' num2str(kes_max_current,4)]);
if(kes_max_current > I_compliance)
    warning("Specified power sweep will exceed compliance current on Keysight!");
    disp(['Compliance current: ' num2str(I_compliance,4)]);
    disp('If you continue, the output (and therefore the power) will be limited by the compliance current.');
    response = input('Continue (y/n)','s');
    if(response ~= 'y')
        return
    end 
end
disp(['Estimated max Keysight voltage (V): ' num2str(kes_est_max_voltage,4)]);
if((kes_est_max_voltage) > V_compliance)
    warning("Specified power sweep might exceed compliance voltage!");
    disp(['Compliance voltage: ' num2str(V_compliance)]);
    disp('If you continue, the output (and therefore the power) will be limited by the compliance voltage.');
    response = input('Continue (y/n)','s');
    if(response ~= 'y')
        return
    end
end
% Configure power supplies as voltage sources with the provided compliance
% AGAIN because otherwise keithley gets stuck in resistance mode (?)
kes_config_I_source(kes, V_compliance);
key_config_I_source(key, V_compliance);
% Set voltage to 0 for safety, we don't know what was on here before
kes_set_V(kes, 0);
key_set_V(key, 0);
% Pre-generate a couple save arrays
key_measured_V = zeros(sweep_number, 1);
key_measured_I = zeros(sweep_number, 1);
kes_measured_V = zeros(sweep_number, 1);
kes_measured_I = zeros(sweep_number, 1); 
optical_power = zeros(sweep_number, 1); 
measurement_times = NaT(sweep_number, 1);
% Set up live plot of interferogram, don't worry about power scaling
f = figure;
p = plot(optical_power);
xlim([0, sweep_number]);
xlabel("Measurement no.");
ylabel("Optical power (mW)");
p.YDataSource = 'optical_power';

% % Setting at beginning 
% settle_index = 1%round(sweep_number/2);
% % WARNING THIS DISRESPECTS CURRENT COMPLIANCE RN
% key_set_I(key, key_current_list(settle_index));
% kes_set_I(kes, kes_current_list(settle_index));
% 
% Turn outputs on
kes_output(kes, true);
key_output(key, true);
% 
% fprintf("key set to %1.2f, kes set to %1.2f for alignment, press enter to continue... \n", ...
%     key_current_list(settle_index), kes_current_list(settle_index));
% pause;

for i_index = 1:sweep_number
    % Get current, respecting compliance
    key_current_point = key_current_list(i_index);
    if(key_current_point > I_compliance)
        warning(['Keithley current compliance triggered! Compliance current '...
            num2str(I_compliance) ' mA used instead of requested current '...
            num2str(key_current_point) 'mA']);
        key_current_point = I_compliance;
    end
    % Set Keysight to current point
    key_set_I(key, key_current_point);

    kes_current_point = kes_current_list(i_index);
    if(kes_current_point > I_compliance)
        warning(['Keysight current compliance triggered! Compliance current '...
            num2str(I_compliance) ' mA used instead of requested current '...
            num2str(kes_current_point) 'mA']);
        kes_current_point = I_compliance;
    end
    % Set Keithley to voltage point
    kes_set_I(kes, kes_current_point);
    
    %key_measure(key); % needed to make keithley actually output???
    pause(settle_time);
    if(i_index == 1)
        fprintf("Settling for %f seconds at first voltage point...", start_pause_time);
        pause(start_pause_time);
    end

    % Measure actual voltage and current after settling
    [key_measured_V(i_index), key_measured_I(i_index)] = key_measure(key);
    [kes_measured_V(i_index), kes_measured_I(i_index)] = kes_measure(kes);
    optical_power(i_index) = laser_get_power(agi);
    % record time that measurements were completed
    measurement_times(i_index) = datetime;
    
    % check if we're hitting V compliance
    if(key_measured_V(i_index) >= V_compliance)
        warning('Keithley measured voltage equals voltage compliance, voltage compliance likely triggered!');
    end
    if(kes_measured_V(i_index) >= V_compliance)
        warning('Keithley measured voltage equals voltage compliance, voltage compliance likely triggered!');
    end

    % Update user with progress
    fprintf("Measurement %d of %d complete (Keysight %1.1f mW, Keithley %1.1f mW) \n", ...
        i_index, sweep_number, ...
        kes_measured_V(i_index)*kes_measured_I(i_index), ...
        key_measured_V(i_index)*key_measured_I(i_index));
    refreshdata; drawnow;
end
    
% Turn outputs off
kes_output(kes, false);
key_output(key, false);

% Calculate actual power (in mW) off of all the individual measurements
key_measured_P = key_measured_I.*key_measured_V;
kes_measured_P = kes_measured_I.*kes_measured_V;
%% Plot Result %%
figure; hold on;
yyaxis left;
plot(key_measured_P, "DisplayName", "Keithley");
plot(kes_measured_P, "DisplayName", "Keysight");
ylabel("Applied Power (mW)");
yyaxis right;
%plot(optical_power);T
plot(10*log10(abs(optical_power)));
ylabel("Measured Optical Power (dBm)");
hold off; legend;
%% Plot resistances %%
figure; hold on;
plot(key_measured_V(2:end-1)./key_measured_I(2:end-1), "DisplayName", "Keithley");
plot(kes_measured_V(2:end-1)./kes_measured_I(2:end-1), "DisplayName", "Keysight");
hold off;
legend;
%% Plot detrended
detrended = optical_power - movmean(optical_power,3);
%detrended = optical_power./movmean(optical_power,3) - 1;
figure;
plot(detrended);
%% Plot FFT
figure;
plot(abs(fft(detrended)));
%% %% Save Result %% %%
% Saves all variables into .mat file (locat. pjusticked using GUI)
% Variables that are probably the Wmost useful:
% - measured_I, measured_P, and measured_V give the actual
%   current/power/voltage output by the Keithley at the beginning of each
%   spectrum measurement, regardless of sweep mode
% - global_params.results gives the transmitted power (in W) at each
%   heater sampling point
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end

