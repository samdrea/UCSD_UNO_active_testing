function kes_output(kes, doTurnOn)
%kes_OUTPUT Turn Keithley output on/off 
    % - kes: keithley VISA object (see kes_start())
    % - doTurnOn: true = on, anything else = off
    if(doTurnOn)
        fwrite(kes, upper(':outp1 on' ));
    else
        fwrite(kes, upper(':outp1 off' ));
    end
end

