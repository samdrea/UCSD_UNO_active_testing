function agilent_setup_logging(laser, numPts, samplTime)
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
    if(~isnumeric(samplTime))
        error("samplTime input must be numeric!");
    end
    if(samplTime < 1e-4)
        error("samplTime (%1.0f us) must be >= 100 us (cannot collect samples faster than 10 kHz)!", 1e6*samplTime)
    end
    % stop any logging that's in progress
    fwrite(laser, ":SENS2:CHAN1:FUNC:STAT LOGG,STOP");
    % setting this on channel 1 (master) also sets for channel 2
    sendStr = sprintf(":SENS2:CHAN1:FUNC:PAR:LOGG %d, %f", ...
        numPts, samplTime);
    fwrite(laser, sendStr);
    %fwrite(laser, '*WAI');
    % check that it actually did what we want

    readParamString = query(laser, ":SENS2:CHAN1:FUNC:PAR:LOGG?");
    readStringSplit = split(readParamString,',');
    readNumSamples = str2double(readStringSplit{1});
    if(readNumSamples ~= numPts)
        warning("Number of points returned by Agilent during logging setup (%d) not equal to number we asked it to log (%d)", ...
        readNumSamples, numPts);
    end
    readIntTime = str2double(readStringSplit{2});
    % note: agilent rounds to nearest of the following integration times:
    % 100 us, 200 us, 500 us, 1 ms, ...
    % if it rounds to an integration time longer than the logging, the
    % result will be glitchy (because it triggers measurements faster than
    % it can take them).
    if(readIntTime > samplTime)
        error(['Agilent detector integration time (%1.1f ms) exceeds ' ...
            'requested sampling period (%1.3f ms)! ' ...
            'This is caused when the Agilent detector rounds up the ' ...
            'requested sampling interval time to the nearest valid ' ...
            'integration time (100 us, 200 us, 500 us) instead of rounding ' ...
            'down. Please adjust settings such that the sampling interval ' ...
            'will round down to 100 us, 200 us, 500 us, 1 ms, etc. ' ...
            'E.g., it is known that logging intervals between ' ...
            '350-499 us do not work, because they round up to 500 us.'], ...
            readIntTime*1e3, samplTime*1e3);
    end
    

end

