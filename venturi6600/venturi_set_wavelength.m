function venturi_set_wavelength(ven, lambdaNm)
    % Set output wavelength in nm
    % TODO handle if TLS is busy
    if(~isnumeric(lambdaNm))
        error("Second input must be numeric!");
    end
    sendStr = sprintf(':CONF:TLS:WAVE %f', lambdaNm);
    result = query(ven, sendStr);
    extracted = venturi_extract_result(result);
    % abuse venturi_extract_result to check for the error
    % message: 'Invalid floating point value'
    if(strcmp(extracted, 'floating'))
        error(result)
    end
    extractedNum = str2double(extracted);
    ERROR_THRESHOLD = 0.1; % how many nm off before we worry
    if(abs(extractedNum - lambdaNm) >= ERROR_THRESHOLD)
        warning('Commanded Venturi to wavelength %1.2f nm, actual power set to %1.2f nm', ...
            lambdaNm, extractedNum);
    end
end

