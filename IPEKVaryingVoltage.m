%{
    Description: Try out the MZI on the Integrated Photonic Education Kit (IPEK) by sweeping various 
    voltages of Keithley power supply and collecting the MZI output power with Venturi6600 OSA
    - Since longer continuous sweeps will heat up IPEK, the voltage sweep will output 0V for a second before 
    testing the subsequent voltage
%}
%% Run before device initialization
clear; % Clear any cached values
delete (instrfindall); % Delete all existing instruments

%% Starting instrument
global key;
key = key_start(); % Initialize and connect Keithley
global agi;
agi = start_laser(); % Initialize the photo detector... was the old laser
ven = venturi_connect(); % Initialize the laser

%% Set up

% Prep Agilent photo detector parameters
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
agilent_set_range(agi, powerMeterRange1, 1);

% Keithley voltage source sweep parameters
v_min = 0; v_max = 5; v_step = 0.01; %0.01; 
v_comp = 5; % IPEK data sheet says 5.1374 V (heats to 30K) and 5.9321 V (heats to 50K)
i_comp = 25; % mA. IPEK data sheet says 29.2 mA (heats to 30K) or 33.7 mA (heats to 50K)
settle_time = 0.1; %0.001; %0.1; % seconds. For voltage to stabilize while I collect data?
global cool_time; 
cool_time = 0.1; % second. Letting IPEK components cool off in between voltages
function_handle = @get_power_and_cool_IPEK; %get_agi_power; get_power_and_cool_IPEK % Will be run everytime Keithley changes voltage 

% Make sure Keithley is set to 2 Wire mode because we can't measure voltage across IPEK's resistor with the other two wires.
key_set_4wire(key, false);

%%  Set laser parameters ( fix paddles to get best alignment )
laser_power_dbm = 4;
laser_wavelength_nm = 1543.85; % 1546.6 nm is around max power, 1543.85 is min
venturi_set_power(ven, laser_power_dbm);
venturi_set_wavelength(ven, laser_wavelength_nm);

%% Turning the laser on
venturi_output(ven, true); 

%% Some test cases
% % Getting instantaneous power from photo detector
% test_array = [];
% data = laser_get_power(agi);
% test_array = [test_array data];
% data = laser_get_power(agi);
% test_array = [test_array data];
% disp(test_array);
% 
% % % Measuring output from Keithley power supply
% % [voltage, current] = key_measure(key);
% % disp(voltage);

%% Actual Sweep
% Sweep Keithley and collect data 
global agilent_results; % mW
agilent_results = [];

[measured_V, measured_I, measured_P] = key_do_V_sweep(...
    key, v_min, v_max, v_step, v_comp, i_comp, settle_time, function_handle);

% Turn laser off
venturi_output(ven, false);

%% For when error arises
% Turn Laser and voltage output off
key_output(key, false);
venturi_output(ven, false);

%% Get max power transmitted
max_power_mW = max(abs(agilent_results));
fprintf('Max power in mW is: %.2f or %.2f dBm\n', max_power_mW, 10*log10(max_power_mW) + 30);

%% Making Graphs in mW
% Plot Voltage vs Power
figure; hold on;
plot(measured_V, agilent_results); % mW display
hold off;
xlabel("Voltage");
ylabel("Power (mW)");

%% Making Graphs in dBm
% Plot Voltage vs Power
figure; hold on;
plot(measured_V, 10*log10(abs(agilent_results))); % dBm display
hold off;
xlabel("Voltage");
ylabel("Power (dBm)");

%%
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'actualRate', 'avgTime', 'laserPower', 'channel1', 'channel2', 'lambdaArray');
else
    disp("File save cancelled");
end

%% Different Functions to do during sweeps
function doNothing()

end

function get_agi_power()
    % Make agilent and its data accessible
    global agilent_results;
    global agi;

    % Collect the instantaneous data point from Agilent
    inst_data = laser_get_power(agi); 
    agilent_results = [agilent_results inst_data];
end

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