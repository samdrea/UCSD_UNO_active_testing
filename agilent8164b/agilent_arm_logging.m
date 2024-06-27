function agilent_arm_logging(agi, detectorRange)
    % turn off continuous measurement
    fwrite(agi, ":INIT2:CONT 0 ");
    % Turn off auto range
    fwrite(agi, 'SENS2:CHAN1:POW:RANG:AUTO 0');
    %Set Power Range
    if(exist('detectorRange'))
        sendStr = sprintf(":SENS2:CHAN1:POW:RANG %1.0f DBM", detectorRange);
        fwrite(agi, sendStr);
    end
    
    % set trigger mode (Complete MEasurement) and "arm" trigger
    fwrite(agi, ":TRIG2:CHAN1:INP CME");
    % REALLY arm trigger
    fwrite(agi, ":SENS2:CHAN1:FUNC:STAT LOGG,STAR");
    % Check that everything is armed
    % This also ensures we wait long enough before exiting this function to
    % avoid race condition
    thisResponse = query(agi, ":SENS2:CHAN1:FUNC:STAT?");
    % this is what's returned if the arming was successful
    progressString = ['LOGGING_STABILITY,PROGRESS' newline()];
    if(~strcmp(thisResponse, progressString))
        warning("Unexpected logging progress response immediately after arming: %s", thisResponse);
    end
end

