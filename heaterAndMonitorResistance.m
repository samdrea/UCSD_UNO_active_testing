clear;
delete (instrfindall); % Delete all existing instruments
global key
kes = kes_start(); % Initialize and connect keithley
key = key_start(); % Initialize and connect keysight

%% Measure two resistances
% Keysight will be used as heater supply, keithley as monitor
kes_set_4wire(kes, false);
key_set_4wire(key, false);
fwrite(key, 'sens:res:mode MAN');
kes_config_I_source(kes, 0.1)
kes_set_I(kes, 0.1);
key_config_I_source(key, 0.1)
key_set_I(key, 0.1);
fprintf("Keithley = %f, Keysight = %f", ...
    key_measure_resistance(key), ...
    kes_measure_resistance(kes));
%% Current sweep on keysight while monitoring keithley
numRepeats = 4;
i_min = 0;
i_max = 100;
i_step = 1;
i_list = i_min:i_step:i_max;
i_num = length(i_list);
v_comp = 21;
i_comp = i_max;
settle_time = 0;
function_handle = @takeKeyResistance;
kes_set_4wire(kes, true);

kesSaveArray = zeros(i_num, 2, numRepeats);
global keyResistances repeatIdx sweepIdx
keyResistances = zeros(i_num, numRepeats);
for repeatIdx = 1:numRepeats
    if(mod(repeatIdx,2))
        thisList = i_list;
    else
        thisList = flip(i_list);
    end
    sweepIdx = 1;
    [measured_V, measured_I, ~] = kes_do_I_list(...
        kes, thisList, v_comp, i_comp, settle_time, function_handle);
    kesSaveArray(:, :, repeatIdx) = [measured_V,measured_I];
end

%% Plot repeats overlaid
figure; hold on;
colors = cool(numRepeats);
for repeatIdx = 1:numRepeats
    plot(kesSaveArray(:,2,repeatIdx), kesSaveArray(:,1,repeatIdx), "Color", colors(repeatIdx, :));
    pause;
end
%% Plot keithley resistance versus current squared of keysight
figure; hold on;
for repeatIdx = 1:numRepeats
    plot(kesSaveArray(:,2,repeatIdx).^2, keyResistances(:, repeatIdx), "Color", colors(repeatIdx, :));
end
%% Random list
numIndividPts = 200;
i_max = 100;
i_list = i_max * rand(numIndividPts,1).^2;
global keyResistances1D
keyResistances1D = zeros(size(i_list));
sweepIdx = 1;
key_output(key, true);
[measured_V, measured_I, ~] = kes_do_I_list(...
        kes, i_list, v_comp, i_comp, settle_time, @takeKeyResistance1D);
key_output(key, false);
%%
plot(measured_I.^2, keyResistances1D, '.');
%% save result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'kesSaveArray', 'settle_time', 'keyResistances');
else
    disp("File save cancelled");
end
%% save random result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'measured_I', 'measured_V', 'keyResistances1D');
else
    disp("File save cancelled");
end

function takeKeyResistance()
    global keyResistances sweepIdx repeatIdx key
    keyResistances(sweepIdx, repeatIdx) = key_measure_resistance(key);
    sweepIdx = sweepIdx + 1;
end

function takeKeyResistance1D()
    global keyResistances1D sweepIdx key
    keyResistances1D(sweepIdx) = key_measure_resistance(key);
    sweepIdx = sweepIdx + 1;
end