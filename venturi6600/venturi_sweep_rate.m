function venturi_sweep_rate(ven,inRate)
    % set sweep rate
    if(~isnumeric(inRate))
        error("Sweep rate must be numeric!");
    end
    
    rateResponse = query(ven, sprintf(':CONF:SWEE:RATE %f', inRate));
    setRate = str2double(venturi_extract_result(rateResponse));
    if(abs(setRate - inRate) >= 0.1)
        warning('Commanded Venturi to sweep rate %1.1f nm/s, actual rate set to %1.1f nm/s', ...
            inRate, setRate);
    end
    if(isnan(setRate))
        error(rateResponse);
    end
    
end

