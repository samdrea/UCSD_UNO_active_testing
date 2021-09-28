%% Program to acquire transmission spectra vs. heater tuning
% See details about data structure storing result in "save results" section
% Program can be safely run in full or in sections
%% %% Initialize Connections to Laser and Power Supply %% %%
delete (instrfindall); % Delete all existing instruments
laser = start_LMS(); % Initialize and connect laser
key = key_start(); % Initialize and connect keithley

%% %% Acquisition Settings %% %%
% Laser source settings
lambda_start = 1460; % nm, minimum 1454
lambda_end = 1500; % nm, maximum 1641
lambda_step = 0.01; % nm
lambda_speed = 10; % sweep speed in nm/s
laser_power = 0;  % dBm, min -10 and max 13 (output 2)

% Optical power meter settings
range = -10; % dB, will be rounded to nearest 10

% Power supply settings
% power supply mode (copied from SweepMode.m)
% - SweepMode.voltage: sweep voltage w/ compliance current
% - SweepMode.current: sweep current w/ compliance voltage
% - SweepMode.power: sweep power in constant mW increments.
%       This is done with a non-uniform voltage sweep.
%       A warning will be issued after measuring the load impedance if the
%       power sweep will exceed either the compliance voltage or current

sweep_mode = SweepMode.current;

% time to wait after changing power supply prior to acquiring spectrum
heater_settle_time = 1; % seconds

% voltage sweep settings (only used if mode is SweepMode.voltage)
V_start = 0; % volts
V_end = 3; % volts
V_step = 1; % volts

% current sweep settings (only used if mode is SweepMode.current)
I_start = 0; % mA
I_end = 50; % mA
I_step = 10; % mA

% power sweep settings (only used if mode is SweepMode.power)
P_start = 0; % mW
P_end = 750; % mW
P_step = 50; % mW

% complaince settings - Keithley output will never exceed either of these,
% regardless of the sweep mode!
I_compliance = 100; % mA
V_compliance = 20; % volts


%% %% Run Acquisition %% %%

% set up for spectra measurements
lambda_list = lambda_start:lambda_step:lambda_end;

% global variable (struct) for passing data to/from sweep function
% this is required because the function handle we past to the sweep
% functions needs to be void-in void-out for simplicity, and as such to
% use or modify any variables those have to be global
global sweep_params;
sweep_params = struct;
sweep_params.laser = laser;
sweep_params.start = lambda_start;
sweep_params.end = lambda_end;
sweep_params.step = lambda_step;
sweep_params.speed = lambda_speed;
sweep_params.power = laser_power;
sweep_params.range = range;
sweep_params.results = [];

% use same function handle for spectrum measurement but switch sweep type
% Matlab is annoying and requires this function definition to be at the end
% of the file, so you can find the code that actually runs the spectrum
% measurement there (doSpectrumMeasurement)

switch(sweep_mode) 
    case SweepMode.voltage
        [measured_V, measured_I, measured_P] = key_do_V_sweep( ...
            key, V_start, V_end, V_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSpectrumMeasurement);
    case SweepMode.current
        [measured_V, measured_I, measured_P] = key_do_I_sweep( ...
            key, I_start, I_end, I_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSpectrumMeasurement);
    case SweepMode.power
        [measured_V, measured_I, measured_P] = key_do_P_sweep( ...
            key, P_start, P_end, P_step, V_compliance, I_compliance, ...
            heater_settle_time, @doSpectrumMeasurement);
    otherwise
        error('Invalid sweep mode!');
end



%% %% Save Result %% %%
% Saves all variables into .mat file (locat. picked using GUI)
% Variables that are probably the most useful:
% - measured_I, measured_P, and measured_V give the actual
%   current/power/voltage output by the Keithley at the beginning of each
%   spectrum measurement
% - sweep_params.results gives the spectra from the sweep as a 2 x [# of
%   lambda points] x [# of heater points] matrix. The spectra of the Nth
%   heater point can be accessed with sweep_params.results(:,:,N), where
%   sweep_params.results(1,:,N) are the wavelengths for each sample and
%   sweep_params.results(2,:,N) is the detected optical power (W) at each
%   wavelength.

[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end

%% %% Plot Result %% %%
% plots all spectra on one plot with blue-to-red color coding
plot_heater_sweep_spectra(sweep_params.results, measured_P, laser_power);

%% Helper functions
% single re-usable function to perform spectrum measurement and save
% result to global variable
function doSpectrumMeasurement() 
    % get access to global struct for this function
    global sweep_params
    % get access to laser
    % setup sweep
    N = laser_scan_setup(sweep_params.laser,sweep_params.speed,...
        sweep_params.step,sweep_params.power,sweep_params.start,...
        sweep_params.end,sweep_params.range);
    % perform sweep
    [lambda, transmission] = laser_scan(sweep_params.laser,N);
    % Add to output data structure
    sweep_params.results = cat(3, sweep_params.results, [lambda;transmission]);
end
