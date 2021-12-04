function key_output(key, doTurnOn)
%KEY_OUTPUT Turn Keithley output on/off 
    % - key: keithley VISA object (see key_start())
    % - doTurnOn: true = on, anything else = off
    if(doTurnOn)
        fwrite(key, 'Output on');
    else
        fwrite(key, 'Output off');
    end
end

