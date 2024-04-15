function agilent_reset_triggers(agi)
    % return Agilent triggers to a state where the power meter auto-updates
    % just in case the logging didn't finish:
    fwrite(agi, ":SENS2:CHAN1:FUNC:STAT LOGG,STOP");
    % continuous back on:
    fwrite(agi, ":INIT2:CONT 1");
    % ignore external triggers
    fwrite(agi, ":TRIG2:CHAN1:INP IGN");
end

