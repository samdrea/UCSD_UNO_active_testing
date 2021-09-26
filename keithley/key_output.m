function key_output(key, doTurnOn)
%KEY_OUTPUT Turn Keithley output on/off (true = on, anything else = off)
%   Detailed explanation goes here
    if(doTurnOn)
        fwrite(key, 'Output on');
    else
        fwrite(key, 'Output off');
    end
end

