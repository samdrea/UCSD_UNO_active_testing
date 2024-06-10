function kes_set_I(kes, current_in, channel, do_milliamps)
% Set output current of keithley in mA - if in V source mode, will do nothing
    % - kes: keithley VISA object (see kes_start())
    % - current: output current in mA
    % Native Keithley unit is amps, but this function uses mA
    
    if(~exist('channel','var'))
        channel = 1; % default to channel 1
    end
    if(~exist('do_milliamps'))
        % this function was originally written to take mA as units - this
        % was a mistake. To enable use with A without breaking old code,
        % add this as an optional argument that defaults to true.
        do_milliamps = true;
    end
    
    if(do_milliamps)
        current_A = current_in/1000;
    else
        current_A = current_in;
    end
    fwrite(kes, sprintf('sour%d:curr:level %f', channel, current_A));
end

