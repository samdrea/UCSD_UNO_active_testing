clear;
delete (instrfindall); % Delete all existing instruments
key = key_start(); % Initialize and connect keithley
%%
fwrite(key, 'sens:res:mode MAN');
key_config_I_source(key, 10);
key_set_I(key, 0.1);
[twoWire, fourWire] = key_contact_resistance(key);
contact = twoWire - fourWire;
fprintf("2-wire = %f, 4-wire = %f, diference = %f \n", twoWire, fourWire, contact);
%% Current sweep
i_min = 0;
i_max = 100;
i_step = 5;
v_comp = 40;
i_comp = i_max;
settle_time = 0;
function_handle = @doNothing;
key_set_4wire(key, true);
[measured_V, measured_I, measured_P] = key_do_I_sweep(...
    key, i_min, i_max, i_step, v_comp, i_comp, settle_time, function_handle);
%% plot IV and differential resistance
figure; hold on;
yyaxis left;
plot(measured_I, measured_V);
xlabel("Applied Current (mA)");
ylabel("Measured Voltage (V)");
yyaxis right; hold on;
plot(measured_I(2:end), 1e3*measured_V(2:end)./measured_I(2:end), "DisplayName", "Resistance");
plot(measured_I(2:end), 1e3*diff(measured_V)./diff(measured_I), "DisplayName", "Differential resistance (ohm)");
ylabel("Resistance (ohm)");
hold off; legend;
%% "Soak" test - see if heater lasts for 1 minute at X current
soak_I = 0.1; % mA
soak_duration = 60; % s
soak_interval = 1; % s
sweep_number = round(soak_duration/soak_interval);
measured_I_soak = zeros(sweep_number, 1);
measured_V_soak = zeros(sweep_number, 1);
measured_R_soak = zeros(sweep_number, 1);
measurement_times = NaT(sweep_number, 1);
%
key_set_I(key, soak_I);
key_config_I_source(key, v_comp);
%
p = plot(measured_R_soak);
xlim([0, sweep_number]);
xlabel("Measurement no.");
ylabel("Resistance (kOhm)");
p.YDataSource = 'measured_R_soak';

key_output(key, true);
for i = 1:sweep_number
    [measured_V_soak(i), measured_I_soak(i)] = key_measure(key);
    measured_R_soak = measured_V_soak ./ measured_I_soak;
    measurement_times(i) = datetime;
    pause(soak_interval);
    refreshdata; drawnow;
end
key_output(key, false);
disp("Done!");
%% save result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename));
else
    disp("File save cancelled");
end

function doNothing()

end