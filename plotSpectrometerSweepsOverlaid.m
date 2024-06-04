[file, location] = uigetfile('.mat', 'Select One or More Files', 'MultiSelect', 'on');
if(iscell(file))
    numFiles = length(file);
else
    numFiles = 1;
    file = {file};
end
%%
figure;
for i = 1:numFiles
    load(fullfile(location, file{i}), ...
        'key_measured_I', 'key_measured_V', 'key_measured_P', ...
        'kes_measured_I', 'kes_measured_V', 'kes_measured_P', ...
        'optical_power', 'measurement_times', 'lambda');
    thisDetrended = optical_power./movmean(optical_power,10);
    %plot(kes_measured_P - key_measured_P, thisDetrended - 1, 'DisplayName', file{i});
    plot(kes_measured_P - key_measured_P, optical_power, 'DisplayName', file{i});
    
    if(i == 1)
        hold on;
    end
end
hold off; legend();
xlabel("Heater power difference (nm)"); ylabel("Optical pwoer (mW)");
%% FFTs
figure; 
for i = 1:numFiles
    load(fullfile(location, file{i}), ...
        'key_measured_I', 'key_measured_V', 'key_measured_P', ...
        'kes_measured_I', 'kes_measured_V', 'kes_measured_P', ...
        'optical_power', 'measurement_times', 'lambda');
    thisDetrended = optical_power./movmean(optical_power,10);
    thisFFT = abs(fft(thisDetrended-1)).^2;
    thisIdx = 1:round(length(thisFFT)/2);
    semilogy(thisFFT(thisIdx), 'DisplayName', sprintf("%1.0fnm", 1e9*lambda));
    if(i == 1)
        hold on;
    end
end
hold off; legend();
xlabel("Arb. FFT x axis units that I don't feel like scaling"); ylabel("Power spectral density");
%% Sweep durations

sweepTimes = []; sweepLambdas = []; sweepTimeSteps = [];
for i = 1:numFiles
    load(fullfile(location, file{i}), 'measurement_times', 'lambda');
    sweepTimes = [sweepTimes measurement_times(end)-measurement_times(1)];
    sweepLambdas = [sweepLambdas lambda];
    sweepTimeSteps = [sweepTimeSteps, seconds(diff(measurement_times))];
end
%plot(sweepLambdas, sweepTimes);
figure; plot(sweepTimeSteps);