function key_set_V(key, voltage)
% Set output voltage of keithley - if in I source mode, will do nothing
    fwrite(key,"sour:volt:level " + num2str(voltage));
end

