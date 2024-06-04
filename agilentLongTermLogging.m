% log output power on Agilent to a file over a decently long period (don't
% do memory in case Matlab crashes
clear; delete(instrfindall);
agi = start_laser(); % legacy function name, not using laser on Agilent
%% select output path
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    full_name = fullfile(output_path, output_filename);
    % check if it exists
    if(isfile(full_name))
        warning("Selected file already exists - results will be appended to this file.");
    end
    
else
    disp("File save cancelled");
end
%% Log power until user ctrl-C's
logPeriod = 1; % period in seconds
loopCount = 0;
disp("Logging in progress...");
while(true)
    pause(logPeriod);
    loopCount = loopCount + 1;
    disp(loopCount);
    dateStr = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss.SSS');
    [power1, power2] = agi_get_power(agi);
    fid = fopen(full_name, 'a');
    fprintf(fid, "%s, %e, %e \r\n", dateStr, power1, power2);
    fclose(fid);
end