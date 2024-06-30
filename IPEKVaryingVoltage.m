%{
    Description: Try out the MZI on the Integrated Photonic Education Kit (IPEK) by sweeping various 
    voltages of Keithley power supply and collecting the MZI output power with Venturi6600 OSA
%}

clear; % Clear any cached values
delete (instrfindall); % Delete all existing instruments
%%
key = key_start(); % Initialize and connect Keithley
agi = start_laser(); % Initialize the photo detector... was the old laser

%% Set up

% Voltage sweep parameters
v_min, v_max, v_step  = 0, 3, 0.01;
v_comp = 4; % IPEK worksheet said don't go over 4 V
i_comp = 2; % mA. Not sure what constant current to set Keithley to
settle_time = 0; % If settle time is 0 seconds, how do I know what the sweep rate is?
function_handle = @doNothing;

% Make sure Keithley is set to 2 Wire mode because we can't measure voltage across IPEK's resistor with the other two wires.
key_set_4wire(key, false);

% Agilent photo detector parameters
scanTime = numPts*avgTime;
max_wait_time = scanTime+5; % time to wait for agilent before timing out
laser.Timeout = max_wait_time; 
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10

% Prep laser and photo detector
agilent_arm_logging(agi); % Configure photo detector to start logging based on Keithley output trigger
agilent_set_range(agi, powerMeterRange1, 1);
agilent_setup_logging(agi, numPts, avgTime);

%% 
% Sweep Keithley and collect data 
[measured_V, measured_I, measured_P] = key_do_V_sweep(...
    key, v_min, v_max, v_step, v_comp, i_comp, settle_time, function_handle)

% Check if photo detector logged data successfully
loggingSuccessful = agilent_wait_for_logging(agi, max_wait_time);
if(loggingSuccessful)
    [channel1, channel2] = agilent_get_logging_result(agi);
    agilent_reset_triggers(agi);
else
    warning("Logging did not finish.");
end

%%
% Plot Voltage vs Power
figure; hold on;
plot(measured_V, 10*log10(abs(channel1)) + 30);
hold off;
xlabel("Voltage");
ylabel("Power (dBm)");
