function kes_set_I(kes, current)
% Set output current of keithley in mA - if in V source mode, will do nothing
    % - kes: keithley VISA object (see kes_start())
    % - current: output current in mA
    % Native Keithley unit is amps, but this function uses mA
    current_mA = current/1000;
    fwrite(kes, ['sour:curr:level ' num2str(current_mA)]);
end

