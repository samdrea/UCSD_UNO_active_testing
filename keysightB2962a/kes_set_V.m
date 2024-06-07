function kes_set_V(kes, voltage, channel)
% Set output voltage of keithley - if in I source mode, will do nothing
    % - kes: keithley VISA object (see kes_start())
    % - voltage: voltage in volts
    if(~exist('channel'))
        channel = 1; % default to channel 1
    end
    fwrite(kes,sprintf("sour%d:volt:level %f", channel, voltage));
end

