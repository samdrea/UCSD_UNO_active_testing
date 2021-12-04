function key_set_V(key, voltage)
% Set output voltage of keithley - if in I source mode, will do nothing
    % - key: keithley VISA object (see key_start())
    % - voltage: voltage in volts
    fwrite(key,"sour:volt:level " + num2str(voltage));
end

