[file, location] = uigetfile('.mat', 'Select One or More Files', 'MultiSelect', 'on');
if(iscell(file))
    numFiles = length(file);
else
    numFiles = 1;
    file = {file};
end
%%
figure; hold on;
for i = 1:numFiles
    clear channel1 channel2 lambdaArray
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'lambdaArray');
    plot(lambdaArray, 10*log10(channel1./channel2), 'DisplayName', file{i});
end
hold off; legend();
xlabel("Wavelength (nm)"); ylabel("Transmission (dB)");
%% FFTs
figure; 
for i = 1:numFiles
    clear channel1 channel2 lambdaArray
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'lambdaArray');
    thisTransmission = channel1./channel2;
    thisTransNorm = thisTransmission; %/max(thisTransmission);
    %thisTransNorm = 10*log10(thisTransmission/max(thisTransmission)); l
    thisFFT = abs(fft(thisTransNorm)).^2;
    thisDlambda = lambdaArray(2)-lambdaArray(1); % assumes uniform
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
    clear channel1 channel2 lambdaArray
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'lambdaArray');
    
    movingFilter = ones(1,numAvg)/numAvg;
    filteredC1 = filter(binomialCoeff, 1, channel1);
    plot(lambdaArray, 10*log10(filteredC1./channel2), 'DisplayName', file{i});
end
hold off