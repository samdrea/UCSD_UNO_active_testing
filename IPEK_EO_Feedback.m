%{
    Description: Attempting to stabilize IPEK MZI output with systematic tuning of voltage
%}
%% Run before device initialization
clear; % Clear any cached values
delete (instrfindall); % Delete all existing instruments

%% Starting instruments
global key;
key = key_start(); % Initialize and connect Keithley
global agi;
agi = start_laser(); % Initialize the photo detector... was the old laser
ven = venturi_connect(); % Initialize the laser

%% Set up

% Set Agilent photo detector parameters
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
agilent_set_range(agi, powerMeterRange1, 1);

% Set laser parameters
laser_power_dbm = 4;
laser_wavelength_nm = 1546.6; % max power for fixing paddles%1543.85; % Test different wavelengths to try to stabilize output
venturi_set_power(ven, laser_power_dbm);
venturi_set_wavelength(ven, laser_wavelength_nm);

%% Turn laser on and fix paddles to get best alignment
venturi_output(ven, true); % Turning the laser on

%% Turn laser back to desired wavelength after alignment
%venturi_output(ven, false); % Depends if i want the laser warm
laser_wavelength_nm = 1543.85;
venturi_set_wavelength(ven, laser_wavelength_nm);

%% Calibration for a and b

% Turn laser on
venturi_output(ven, true); % Turning the laser on

% Keithley voltage source sweep parameters
v_min = 0.5; v_max = 4; v_step = 0.01; %0.01; 
v_comp = 5; % IPEK data sheet says 5.1374 V (heats to 30K) and 5.9321 V (heats to 50K)
i_comp = 25; % mA. IPEK data sheet says 29.2 mA (heats to 30K) or 33.7 mA (heats to 50K)
settle_time = 0.1; %0.001; %0.1; % seconds. For voltage to stabilize while I collect data?
global cool_time; 
cool_time = 0.1; % second. Letting IPEK components cool off in between voltages
function_handle = @get_power_and_cool_IPEK; %get_agi_power; get_power_and_cool_IPEK % Will be run everytime Keithley changes voltage 
key_set_4wire(key, false); % Set Keithley to 2 wire mode

% Actual Sweep
% Sweep Keithley and collect data 
global agilent_results; % mW
agilent_results = [];

[measured_V, measured_I, measured_P] = key_do_V_sweep(...
    key, v_min, v_max, v_step, v_comp, i_comp, settle_time, function_handle);

% Turn laser off
venturi_output(ven, false);

%% Get a and b
% Finding the voltage of lowest power as offset
[min_value, index] = min(agilent_results); % Find the minimum value in agilent_results and its index
V_offset = measured_V(index); % Should be around 0.7

% Finding greatest P after going through IPEK
P_max = max(agilent_results);

% Find the indices of values within the specified range in agilent_results
P_ratio = 0.6; % How much of P_max we want our high-state voltage to be
lower_bound = P_max * P_ratio - 0.0005;
upper_bound = P_max * P_ratio + 0.0005;
possible_indices = find(agilent_results >= lower_bound & agilent_results <= upper_bound);

% Finding the power and voltage of our "high-state" (the last will be the
% one going downhill
V_working = measured_V(possible_indices(end));
P_working = agilent_results(possible_indices(end));

% Calculating the constants
a = asin(sqrt(P_working/P_max))/(V_working-V_offset);
b = (V_working-V_offset)/P_working;

% Create the formatted string
output_str = sprintf('\nCalculated values:\na = %.4f V^-1\nb = %.4f V/mW \nP _max = %.4f mW \nP_working = %.4f mW \nV_offset = %.4f V \nV_working = %.4f V', ...
                     a, b, P_max, P_working, V_offset, V_working);

% Print the formatted string
disp(output_str);

%% Look at graph if I want to verify
% Plot Voltage vs Power
figure; hold on;
plot(measured_V, agilent_results); % mW display
hold off;
xlabel("Voltage");
ylabel("Power (mW)");

%% Setup EO feedback loop variables

% Create arrays to collect data
tuning_voltage_arr = []; % volts.
measured_power_arr = []; % mW.
predicted_power_arr = []; % mW.

% Set feedback loop variables
input_voltage = 3.55; % volts
num_iter = 10;
%P_max =  0.01354; % mW. Equal to our power input. Can probably use 1000 * 10 ** ((laser_power_dbm - 30) / 10)) 
%a = 0.2322; % V^-1. Constant of proportionality for transmitted power  
%b = 541.8719; % V/mW. Constant for proportionality for power to voltage conversion
V_max = 5; %V. Don't exceed this


%% Run EO feedback loop

% Turn laser on
venturi_output(ven, true);

% Set Keithley voltage to 0 for safety before turning on
key_set_V(key, 0);
    
% Turn Keithley output on
key_output(key, true);

for i = 1:num_iter 

    % Test the input voltage to tune MZI
    key_set_V(key, input_voltage);
    [measured_voltage , measured_current] = key_measure(key); % Get the actual voltage output 
    tuning_voltage_arr = [tuning_voltage_arr measured_voltage]; % Record the actual voltage output

    % Wait for voltage to take effect?
    pause(0.1); % Seconds

    % Collect output power
    curr_power = laser_get_power(agi); % Read in mW
    measured_power_arr = [measured_power_arr curr_power];
    predicted_power = P_max * (sin(a * input_voltage)) ^ 2;
    predicted_power_arr = [predicted_power_arr predicted_power];

    % Let IPEK cool before next voltage
    key_set_V(key, 0);
    pause(0.1); % seconds

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

%% Plot for Voltage and Power vs. Iteration
% Define an iteration array
iterations = 1:num_iter;


% Create a figure
figure;

% Plot the data with two y-axes
yyaxis left
plot(iterations, tuning_voltage_arr, '-o', 'Color', 'b', 'DisplayName', 'Tuning Voltage');
ylabel('Voltage (V)');

yyaxis right
plot(iterations, measured_power_arr, '-x', 'Color', 'r', 'DisplayName', 'Measured Power');
ylabel('Power (mW)');

% Add labels and title
xlabel('Iteration');
title('Voltage and Power vs. Iteration');
legend('show');
grid on;

% Create the annotation string
annotation_str = sprintf(['Calculated values:\n' ...
                          'a = %.4f\n' ...
                          'b = %.4f\n' ...
                          'P_{max} = %.4f mW\n' ...
                          'P_{working} = %.4f mW\n' ...
                          'V_{working} = %.4f V\n' ...
                          'V_{offset} = %.4f V\n' ...
                          'Wavelength = %.4f nm\n' ...
                          'Power Input = %.4f mW'], ...
                          a, b, P_max, P_working, V_working, V_offset, laser_wavelength_nm, 10 * log10(laser_power_dbm));

% Add annotation to the plot
dim = [0.15 0.7 0.3 0.2]; % [x y w h] position of annotation (adjust as needed)
annotation('textbox', dim, 'String', annotation_str, 'FitBoxToText', 'on', 'BackgroundColor', 'white');

%%  Plot for iteration vs power
%Create a figure
figure; 

% Plot the measured power against iterations
plot(iterations, measured_power_arr, '-x', 'Color', 'b', 'DisplayName', 'Measured Power');
hold on; % Hold the current plot

% Plot the predicted power against iterations
plot(iterations, predicted_power_arr, '-o', 'Color', 'r', 'DisplayName', 'Predicted Power'); 

% Add labels and title
xlabel('Iteration');
ylabel('Power (mW)');
title('Power vs. Iteration');
legend;
grid on;
hold off;

%% Plot for voltage vs power graph
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
legend;
grid on;
hold off;


%% Helper functions
function get_power_and_cool_IPEK()
    % Make agilent and its data accessible
    global agilent_results;
    global agi;
    global cool_time;
    global key;
    

    % Collect the instantaneous data point from Agilent
    inst_data = laser_get_power(agi); 
    agilent_results = [agilent_results inst_data];

    % Cool the IPEK down before the next voltage change
    key_set_V(key, 0);
    pause(cool_time);
end