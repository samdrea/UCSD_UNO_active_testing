clear;
delete (instrfindall); % Delete all existing instruments
key = key_start(); % Initialize and connect keithley
%%
key_config_I_source(key, 0.1)
key_set_I(key, 0.1);
[twoWire, fourWire] = key_contact_resistance(key);
contact = twoWire - fourWire;
fprintf("2-wire = %f, 4-wire = %f, diference = %f \n", twoWire, fourWire, contact);
%% Current sweep, with repeats.
numRepeats = 20;
i_min = 0;
i_max = 250;
i_step = 10;
i_list = i_min:i_step:i_max;
i_num = length(i_list);
v_comp = 21;
i_comp = i_max;
settle_time = 0;
function_handle = @doNothing;
key_set_4wire(key, true);
saveArray = zeros(i_num, 2, numRepeats);
for repeatIdx = 1:numRepeats
    if(mod(repeatIdx,2))
        thisList = i_list;
    else
        thisList = flip(i_list);
    end
    [measured_V, measured_I, ~] = key_do_I_list(...
        key, thisList, v_comp, i_comp, settle_time, function_handle);
    saveArray(:, :, repeatIdx) = [measured_V,measured_I];
end

%% Plot repeats overlaid
figure; hold on;
colors = cool(numRepeats);
for repeatIdx = 1:numRepeats
    plot(saveArray(:,2,repeatIdx), saveArray(:,1,repeatIdx), "Color", colors(repeatIdx, :));
    pause;
end
%% Random list
numIndividPts = 1000;
i_list = i_max * rand(numIndividPts);
[measured_V, measured_I, ~] = key_do_I_list(...
        key, i_list, v_comp, i_comp, settle_time, function_handle);
%%
plot(measured_I, measured_V, '.');
%% save result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'saveArray', 'settle_time');
else
    disp("File save cancelled");
end
%% save random result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'measured_I', 'measured_V');
else
    disp("File save cancelled");
end

function doNothing()

end