%{
    Description: Try out the MZI on the Integrated Photonic Education Kit (IPEK) by sweeping various 
    wavelengths of Agilent8164b laser and collecting the power with Venturi6600 photo detector

    TODO: Could vary the Voltage on the Keithley
%}


clear; % Clear all variables
delete(instrfindall); % Delete any previous device configurations

%%
ven = venturi_connect(); % Initialize the laser
agi = start_laser(); % Initialize the photo detector... was the old laser


%% Setup laser sweep parameters
startWavelength = 1540; % nm
stopWavelength = 1560; % nm
sweepRate = 10; % nm/s (limited by venturi collection rate)
wavelengthStep = 0.005; 
laserPower = 4; % dBm, 0 to 9.9

% Setup laser 
venturi_set_power(ven, laserPower);
[actualRange, actualRate] = venturi_sweep_setup(ven, sweepRate, startWavelength, stopWavelength); % Record actual laser parameters

% The time interval in which each logged data point is averaged over
avgTime = wavelengthStep/actualRate;

% The number of time intervals for collecting data 
numPts = actualRange/wavelengthStep;

% The array of wavelengths that each logged avg power will correspond to
lambdaArray = startWavelength + wavelengthStep*(0.5 + 0:(numPts));

% Setup the range of intensity the photo detector will collect data from?
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
powerMeterRange2 = 10; % dBm, multiples of 10 from -60 to 10

% Setup the photo detector 
agilent_set_range(agi, powerMeterRange1, 1);
agilent_set_range(agi, powerMeterRange2, 2);  % Probably will not need this?
agilent_setup_logging(agi, numPts, avgTime);

% Setup photo detector timeout
scanTime = numPts*avgTime;
max_wait_time = scanTime+5; % time to wait for agilent before timing out
laser.Timeout = max_wait_time; 

% Prep laser and photo detector
agilent_arm_logging(agi); % Configure photo detector to start logging based on laser trigger
venturi_output(ven, true); % Configure laser to output signal to photo detector

% Sweep laser... why is there two?
venturi_sweep_run(ven); 
%venturi_sweep_run(ven);

% Check if photo detector logged data successfully
loggingSuccessful = agilent_wait_for_logging(agi, max_wait_time);
if(loggingSuccessful)
    [channel1, channel2] = agilent_get_logging_result(agi);
    agilent_reset_triggers(agi);
else
    warning("Logging did not finish.");
end

%%
% Plot Wavelength vs Power
figure; hold on;
plot(lambdaArray, 10*log10(abs(channel1)) + 30);
%plot(lambdaArray, 10*log10(channel2) + 30);
hold off;
xlabel("Wavelength");
ylabel("Power (dBm)");

%% Save the figure as a PNG file
exportgraphics(gcf, '0.25stepsize.png', 'Resolution', 600); % 600 DPI is very detailed for print. 1000 is extremly detailed


%%
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'actualRate', 'avgTime', 'laserPower', 'channel1', 'channel2', 'lambdaArray');
else
    disp("File save cancelled");
end

