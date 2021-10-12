%% Program to acquire single wavelength transmission vs. heater tuning
% Program can be safely run in full or in sections
%% %% Initialize Connections to Laser and Power Supply %% %%
delete (instrfindall); % Delete all existing instruments
laser = start_LMS(); % Initialize and connect laser
key = key_start(); % Initialize and connect keithley

%% %% Acquisition Settings %% %%
% Laser source settings
lambda = 1550; % nm, minimum 1454, maximum 1641
laser_power = 0;  % dBm, min -10 and max 13 (output 2)

% Power supply settings
% power supply mode (copied from SweepMode.m)
% - SweepMode.voltage: sweep voltage w/ compliance current
% - SweepMode.current: sweep current w/ compliance voltage
% - SweepMode.power: sweep power in constant mW increments.
%       This is done with a non-uniform voltage sweep.
%       A warning will be issued after measuring the load impedance if the
%       power sweep will exceed either the compliance voltage or current

sweep_mode = SweepMode.current;

% time to wait after changing power supply prior to taking measurements
heater_settle_time = 0.25; % seconds

% voltage sweep settings (only used if mode is SweepMode.voltage)
V_start = 0; % volts
V_end = 10; % volts
V_step = 1; % volts

% current sweep settings (only used if mode is SweepMode.current)
I_start = 0; % mA
I_end = 100; % mA
I_step = 10; % mA

% power sweep settings (only used if mode is SweepMode.power)
P_start = 0; % mW
P_end = 1000; % mW
P_step = 25; % mW

% complaince settings - Keithley output will never exceed either of these,
% regardless of the sweep mode!
I_compliance = 100; % mA
V_compliance = 5; % volts


%% %% Run Acquisition %% %%

% global variable (struct) for passing data to/from measurement function
% this is required because the function handle we past to the sweep
% functions needs to be void-in void-out for simplicity, and as such to
% use or modify any variables those have to be global
global global_params;
global_params = struct;
global_params.laser = laser;
global_params.results = [];

% set laser params
laser_set_basic_params(laser, laser_power, lambda);

% turn on laser
laser_output(laser, true);

% use same function handle for optical measurement but switch sweep type
% Matlab is annoying and requires this function definition to be at the end
% of the file, so you can find the code that actually runs the measurement
% and saves the data there (doSingleWavelengthMeasurement)
switch(sweep_mode) 
    case SweepMode.voltage
        [measured_V, measured_I, measured_P] = key_do_V_sweep( ...
            key, V_start, V_end, V_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSingleWavelengthMeasurement);
    case SweepMode.current
        [measured_V, measured_I, measured_P] = key_do_I_sweep( ...
            key, I_start, I_end, I_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSingleWavelengthMeasurement);
    case SweepMode.power
        [measured_V, measured_I, measured_P] = key_do_P_sweep( ...
            key, P_start, P_end, P_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSingleWavelengthMeasurement);
    otherwise
        laser_output(laser, false);
        error('Invalid sweep mode!');
end

% turn off laser
laser_output(laser, false);
%% %% Save Result %% %%
% Saves all variables into .mat file (locat. picked using GUI)
% Variables that are probably the most useful:
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

%% %% Plot Result %% %%
laser_power_mW = 10^(laser_power/10);
plot(measured_P, 10*log10(global_params.results/laser_power_mW));
xlabel("Heater Power (mW)");
ylabel("Transmission (dB)");
%% Helper functions
% single re-usable function to perform spectrum measurement and save
% result to global variable
function doSingleWavelengthMeasurement() 
    % get access to global struct for this function
    global global_params
    % add to results
    global_params.results = [global_params.results laser_get_power(global_params.laser)];
end
