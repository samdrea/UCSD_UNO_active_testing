function [voltage , current] = kes_measure(kes)
%kes_MEASURE Measure voltage (V) and current (mA) output of Keithely
    % - kes: keithley VISA object (see kes_start())
    %iv = query(kes, 'read?');          % voltage, current, resistance, time, status
    %str1 = regexp(iv,',','split');     % splits data separted by ','
    voltage = str2double(query(kes, ':meas:volt?'));
    current = 1000.0*str2double(query(kes, ':meas:curr?'));
end

