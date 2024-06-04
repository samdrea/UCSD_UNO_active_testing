%% Shift-click to select multiple files that will be plotted
[file, location] = uigetfile('.mat', 'Select One or More Files', 'MultiSelect', 'on');
if(iscell(file))
    numFiles = length(file);
else
    numFiles = 1;
    file = {file};
end
%% Plot spectra overlaid, normalized to max. 1-channel only
figure; hold on;
colors = cool(numFiles);
for i = 1:numFiles
%     clear channel1 channel2 wvs
%     load(fullfile(location, file{i}), 'channel1', 'channel2', 'wvs');
    clear channel1 wvs
    load(fullfile(location, file{i}), 'channel1', 'wvs');
    %plot(wvs, 10*log10(channel1), 'DisplayName', file{i});
    thisColor = colors(i,:);
    plot(wvs, 10*log10(channel1./max(channel1)), '.-', 'DisplayName', file{i}, ...
        'Color', thisColor);
end
hold off; l = legend(); l.Interpreter = "none";
xlabel("Wavelength (nm)"); ylabel("Transmission (dB)");
%% FFTs
figure;
for i = 1:numFiles
    clear channel1 channel2 wvs
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'wvs');
    thisTransmission = channel1./max(channel1);
    thisTransNorm = thisTransmission; %/max(thisTransmission);
    %thisTransNorm = 10*log10(thisTransmission/max(thisTransmission)); l
    thisFFT = abs(fft(thisTransNorm)).^2;
    thisDlambda = wvs(2)-wvs(1); % assumes uniform
    N = length(thisFFT);
    thisFreqAxis = (0:N-1)/(N*thisDlambda); thisMaxN = round(N/2);
    loglog(thisFreqAxis(1:thisMaxN), thisFFT(1:thisMaxN), 'DisplayName', file{i});
    if(i == 1)
        hold on;
    end
end
hold off; legend();
xlabel("Inverse wavelength units (nm^-1)"); ylabel("Power spectral density");

%% low pass filter
numAvg = 50;
h = [1/2 1/2];
binomialCoeff = conv(h,h);
for n = 1:numAvg
    binomialCoeff = conv(binomialCoeff, h);
end

numFiles = length(file);
figure; hold on;
for i = 1:numFiles
    clear channel1 channel2 wvs
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'wvs');
    
    movingFilter = ones(1,numAvg)/numAvg;
    filteredC1 = filter(binomialCoeff, 1, channel1);
    plot(wvs, 10*log10(filteredC1./channel2), 'DisplayName', file{i});
end
hold off