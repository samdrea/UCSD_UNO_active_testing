%{
    Description: Try out the MZI on the Integrated Photonic Education Kit (IPEK) by sweeping various 
    voltages of Keithley power supply and collecting the MZI output power with Venturi6600 OSA
%}
%% Run before device initialization
clear; % Clear any cached values
delete (instrfindall); % Delete all existing instruments

%% Starting instrument
key = key_start(); % Initialize and connect Keithley
global agi;
agi = start_laser(); % Initialize the photo detector... was the old laser
ven = venturi_connect(); % Initialize the laser

%% Set up

% Prep Agilent photo detector parameters
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
agilent_set_range(agi, powerMeterRange1, 1);
global agilent_results;
agilent_results = [];

% Keithley voltage source sweep parameters
v_min = 0; v_max = 4; v_step = 0.1;
v_comp = 5; % IPEK data sheet says 5.1374 V (heats to 30K) and 5.9321 V (heats to 50K)
i_comp = 25; % mA. IPEK data sheet says 29.2 mA (heats to 30K) or 33.7 mA (heats to 50K)
settle_time = 0.01; %0.1; % seconds. For voltage to stabilize while I collect data?
function_handle = @get_agi_power; %@doNothing; % Will be run everytime Keithley changes voltage 

% Make sure Keithley is set to 2 Wire mode because we can't measure voltage across IPEK's resistor with the other two wires.
key_set_4wire(key, false);

%%  Turn laser on and fix paddles to get best alignment
laser_power_dbm = 4;
laser_wavelength_nm = 1550;
venturi_set_power(ven, laser_power_dbm);
venturi_set_wavelength(ven, laser_wavelength_nm);
venturi_output(ven, true); % Turning the laser on

%% Some test cases
% Getting instantaneous power from photo detector
test_array = [];
data = laser_get_power(agi);
test_array = [test_array data];
data = laser_get_power(agi);
test_array = [test_array data];
disp(test_array);

% % Measuring output from Keithley power supply
% [voltage, current] = key_measure(key);
% disp(voltage);

%% Actual Sweep
% Sweep Keithley and collect data 
[measured_V, measured_I, measured_P] = key_do_V_sweep(...
    key, v_min, v_max, v_step, v_comp, i_comp, settle_time, function_handle);

% Turn laser off
venturi_output(ven, false);

%% For when error arises
% Turn Laser and voltage output off
key_output(key, false);
venturi_output(ven, false);

%% Making Graphs
% Plot Voltage vs Power
figure; hold on;
plot(measured_V, 10*log10(abs(agilent_results)) + 30);
hold off;
xlabel("Voltage");
ylabel("Power (dBm)");

%% Helper Functions
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