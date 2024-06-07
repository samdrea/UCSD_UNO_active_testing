% spectrometer sweep where we quickly ramp two heaters at the same time 
% using channels 1 and 2 on keithley
clear;
delete (instrfindall); % Delete all existing instruments
agi = start_laser(); % Initialize and connect Agilent power meter
% ven = venturi_connect(); % Connect to Venturi laser
kes = kes_start(); % Connect to keysight
%% Sweep parameters and send to equipment
detector_range = -50;
% how often to sample, seconds.
sampling_interval = 1e-3;

low_voltage = 0;
high_voltage = 1;
num_repeat = 1;
i_compliance = 1e-3;
start_time = 0.5;
ramp_time = 1;
end_time = 0.5;
% collect data over start, ramp, and end
total_time = start_time + ramp_time + end_time;
sampling_num = ceil(total_time/sampling_interval);
time_array = 0:sampling_interval:total_time;
% hacky fix of off-by-one
time_array = time_array(1:end-1);
% use agilent "logging" mode which maximizes integration time for given
% sampling period
agilent_setup_logging(agi, sampling_num, sampling_interval);
% "background" voltages - what is on when the ramp isn't running?
background_voltage_1 = 0.5;
background_voltage_2 = 0.5;

% channel 1 up-ramp
kes_setup_lin_volt_ramp(...
            kes, ... % keysight VISA object
            1, ... % output channel, 1 or 2
            num_repeat, ... % repeat ramp this many times
            start_time, ... % begin ramp this long after trigger (s)
            ramp_time, ... % take this long to ramp up (s)
            end_time, ... % stay at end voltage for this long (s)
            low_voltage, ... % start voltage (V)
            high_voltage, ... % end voltage (V)
            i_compliance); % compliance current (A)
kes_set_V(kes, background_voltage_1, 1);
% channel 2 down-ramp
kes_setup_lin_volt_ramp(kes,  2, num_repeat, start_time, ... 
            ramp_time, end_time, high_voltage, low_voltage, i_compliance);
kes_set_V(kes, background_voltage_2, 2);
% note: might want to turn on outputs here
%% Run sweep
agilent_arm_logging(agi, detector_range);
kes_trig_ramp(kes);
% usually we would have hardware trigger but for now software trigger
% agilent
fwrite(agi,'*WAI');
fwrite(agi, "trig 1");
max_wait_time = total_time + 5; % time to wait for agilent before timing out
laser.Timeout = max_wait_time;
loggingSuccessful = agilent_wait_for_logging(agi, max_wait_time);
% turn off outputs
kes_output(kes, false);
% get result
% TODO DO MEASUREMENT ON KEYSIGHT POWER SUPPLY TOO
if(loggingSuccessful)
    [channel1, channel2] = agilent_get_logging_result(agi);
    agilent_reset_triggers(agi);
else
    warning("Logging did not finish in alloted time.");
end
%% Plot result
figure; hold on;
plot(time_array, 10*log10(abs(channel1)) + 30, 'r-');
plot(time_array, 10*log10(abs(channel2)) + 30), 'b-';
hold off;
xlabel("Wavelength");
ylabel("Power (dBm)");