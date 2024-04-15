function agilent_setup_logging(laser, numPts, avgTime)
    % Setup dual-channel power meter logging, e.g. for Venturi laser sweep
    % this currently only triggers in response to a hardware trigger
    % numPts: number of data points to capture (max 20,000)
    % avgTime: period of data point capture in seconds, same as integration time
    if(~isnumeric(numPts))
        error("numPts input must be numeric!");
    end
    if(numPts > 20000)
        error("Number of points for Agilent power meter logging cannot exceeed 20,000");
    elseif(numPts < 1)
        error("Number of points for Agilent power meter logging must be at least 1");
    end
    if(~isnumeric(avgTime))
        error("avgTime input must be numeric!");
    end
    % stop any logging that's in progress
    fwrite(laser, ":SENS2:CHAN1:FUNC:STAT LOGG,STOP");
    % setting this on channel 1 (master) also sets for channel 2
    sendStr = sprintf(":SENS2:CHAN1:FUNC:PAR:LOGG %d, %f", ...
        numPts, avgTime);
    fwrite(laser, sendStr);
    %fwrite(laser, '*WAI');
    % check that it actually did what we want
    
    % turn off continuous measurement
    fwrite(laser, ":INIT2:CONT 0 ");
    
    % set trigger mode (Complete MEasurement) and "arm" trigger
    fwrite(laser, ":TRIG2:CHAN1:INP CME");
    % REALLY arm trigger
    fwrite(laser, ":SENS2:CHAN1:FUNC:STAT LOGG,STAR");
end

