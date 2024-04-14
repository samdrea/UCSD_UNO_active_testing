%% Program to acquire single transmission spectrum from 8164B
%% Initialize Connection to Laser
delete (instrfindall); % Delete all existing instruments
%laser = start_laser(); % Initialize and connect laser
laser = start_laser_8163b(); % Initialize and connect laser

%% Acquisition Parameters
% Laser source settings (all in nm)
lambda_start = 1540; % nm, minimum 1460
lambda_end = 1560; % nm, maximum 1600
lambda_step = 0.005; % nm, minimum TODO
lambda_speed = 1; % sweep speed in nm/s, min TODO and max TODO
laser_power = 6;  %dbm, min TODO and max TODO (on output 2)
% TODO actually measure what the laser power was set to to check for errors
% Optical power meter settings
range = -40; % dB, will be rounded to nearest 10
%% Run Acquisition
N = laser_scan_setup(laser,lambda_speed,lambda_step,laser_power,lambda_start,lambda_end,range);
[lambdaList,transmissionList] = laser_scan(laser,N);
%% Plot result
transmissionListmW = transmissionList*1000;
laser_power_mW = 10^(laser_power/10);
figure;
plot(lambdaList, 10*log10(transmissionListmW/laser_power_mW));
xlabel("Wavelength");
ylabel("Transmission (dB)");
%% %% Save Result %% %%
% Saves all variables into .mat file (locat. picked using GUI)
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end
