function agilent_arm_logging(agi, detectorRange)
    % turn off continuous measurement
    fwrite(agi, ":INIT2:CONT 0 ");
    % Turn off auto range
    fwrite(agi, 'SENS2:CHAN1:POW:RANG:AUTO 0');
    %Set Power Range
    sendStr = sprintf(":SENS2:CHAN1:POW:RANG %1.0f DBM", detectorRange);
    fwrite(agi, sendStr);
    
    % set trigger mode (Complete MEasurement) and "arm" trigger
    fwrite(agi, ":TRIG2:CHAN1:INP CME");
    % REALLY arm trigger
    fwrite(agi, ":SENS2:CHAN1:FUNC:STAT LOGG,STAR");
end

