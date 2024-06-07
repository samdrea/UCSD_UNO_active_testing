function kes_output(kes, doTurnOn)
%kes_OUTPUT Turn Keithley output on/off 
    % - kes: keithley VISA object (see kes_start())
    % - doTurnOn: true = on, anything else = off
    % applies to both channels! TODO separate controls
    if(doTurnOn)
        fwrite(kes, upper(':outp1 on' ));
        fwrite(kes, upper(':outp2 on' ));
    else
        fwrite(kes, upper(':outp1 off' ));
        fwrite(kes, upper(':outp2 off' ));
    end
end

