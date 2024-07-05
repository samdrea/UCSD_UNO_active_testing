%{
    Description: Attempting to stabilize IPEK MZI output with systematic tuning of voltage
%}
%% Run before device initialization
clear; % Clear any cached values
delete (instrfindall); % Delete all existing instruments

%% Starting instruments
key = key_start(); % Initialize and connect Keithley
global agi;
agi = start_laser(); % Initialize the photo detector... was the old laser
ven = venturi_connect(); % Initialize the laser

%% Set up

% Set Agilent photo detector parameters
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
agilent_set_range(agi, powerMeterRange1, 1);

% Set Keithley to voltage source with current compliance
i_comp_mA = 25 % IPEK data sheet says 29.2 mA (heats to 30K) or 33.7 mA (heats to 50K)
key_config_V_source(key, i_comp_mA);

% Set laser parameters
laser_power_dbm = 4;
laser_wavelength_nm = 1550; % Use the trough when sweeping wavelength (experimentally found)
venturi_set_power(ven, laser_power_dbm);
venturi_set_wavelength(ven, laser_wavelength_nm);

%%  Turn laser on and fix paddles to get best alignment
venturi_output(ven, true); % Turning the laser on

%% Turn laser off after alignment
venturi_output(ven, false);

%% Setup EO feedback loop variables

% Create arrays to collect data
tuning_voltage_arr = []; % volts.
measured_power_arr = []; % mW.
predicted_power_arr = []; % mW.

% Set feedback loop variables
input_voltage = 0; % volts
num_iter = 10;
V_max = 0; % volts. Max voltage to for transmittance to go from 0 to slightly > 1 (experimentally found)
P_0 = 0; % mW. Max output power (experimentally found)
a = pi / (2 * V_max); % Constant of proportionality for transmitted power  
b = V_max / P_0; % Constant for proportionality for power to voltage conversion

% Verify constants 
fprintf('Constants a: %d, b: %d\n', a, b);

%% Run EO feedback loop

% Turn laser on
venturi_output(ven, true);

for i = 1:num_iter 

    % Test the input voltage to tune MZI
    key_set_V(key, input_voltage);
    [measured_voltage , measured_current] = key_measure(key); % Get the actual voltage output 
    tuning_voltage_arr = [tuning_voltage_arr measured_voltage]; % Record the actual voltage output

    % Wait for voltage to take effect?
    pause(0.5); % Seconds

    % Collect output power
    curr_power = laser_get_power(agi);
    measured_power_arr = [measured_power_arr curr_power];
    predicted_power = P_0 * (sin(a * input_voltage)) ** 2;
    predicted_power_arr = [predicted_power_arr predicted_power];

    % Calculate next tuning voltage based on output power 
    input_voltage = b * curr_power;

    % Make sure the next voltage to be tested is within our range
    if input_voltage > V_max
        fprintf('Input voltage greater than max voltage: %d\n Iterations ending prematurely...', input_voltage);
        break; % Exit the loop
    end
end

% Turn laser and voltage source off
venturi_output(ven, false);
key_output(key, false);

%% For when error arises
% Turn Laser and voltage output off
key_output(key, false);
venturi_output(ven, false);

%% Making Graphs

figure; % Create the figure

% Plot the output power
plot(tuning_voltage_arr, measured_power_arr, '-x', 'Color', 'b', 'DisplayName', 'Measured Power'); 
hold on; % Hold the current plot

% Plot the predicted power
plot(tuning_voltage_arr, predicted_power_arr, '-o', 'Color', 'r', 'DisplayName', 'Predicted Power'); 

% Add labels and title
xlabel('Voltage (V)');
ylabel('Power (mW)');
title('Measured Power vs. Predicted Power');

% Add a legend
legend;

% Show grid
grid on;

% Release the hold
hold off;

%% Save the figure as a PNG file
exportgraphics(gcf, '#_iter.png', 'Resolution', 600); % 600 DPI is very detailed for print. 1000 is extremly detailed



