function venturi_set_power(ven, powerDbm)
    % Set output power in dBm
    if(~isnumeric(powerDbm))
        error("Second input must be numeric!");
    end
    sendStr = sprintf(':CONF:TLS:POWE %f', powerDbm);
    result = query(ven, sendStr);
    extracted = venturi_extract_result(result);
    % abuse venturi_extract_result to check for the error
    % message: 'Invalid floating point value'
    if(strcmp(extracted, 'floating'))
        error(result)
    end
    extractedNum = str2double(extracted);
    ERROR_THRESHOLD = 0.05; % how many dBm off before we worry
    if(abs(extractedNum - powerDbm) >= ERROR_THRESHOLD)
        warning('Commanded Venturi to power %1.1f dBm, actual power set to %1.1f dBm', ...
            powerDbm, extractedNum);
    end
end

