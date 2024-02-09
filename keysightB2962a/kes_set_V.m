function kes_set_V(kes, voltage)
% Set output voltage of keithley - if in I source mode, will do nothing
    % - kes: keithley VISA object (see kes_start())
    % - voltage: voltage in volts
    fwrite(kes,"sour:volt:level " + num2str(voltage));
end

