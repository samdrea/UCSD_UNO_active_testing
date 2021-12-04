function [voltage , current] = key_measure(key)
%KEY_MEASURE Measure voltage (V) and current (mA) output of Keithely
    % - key: keithley VISA object (see key_start())
    iv = query(key, 'read?');          % voltage, current, resistance, time, status
    str1 = regexp(iv,',','split');     % splits data separted by ','
    voltage = str2double(str1{1});
    current = 1000*str2double(str1{2});
end

