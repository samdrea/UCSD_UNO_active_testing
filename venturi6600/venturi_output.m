function venturi_output(ven, doTurnOn)
    % Function to turn laser output on/off
    if(doTurnOn)
        % Laser output ON
        result = query(ven, ':CONF:TLS:OUTP ON');
        extracted = venturi_extract_result(result);
        if(strcmp(extracted,'Locked'))
            % check if laser is locked
            error("Venturi software interlock active. De-activate in Menu -> Output Control -> Lock/Unlock");
        elseif(~strcmp(extracted,'On'))
            error(result);
        end
    else
        % Laser output OFF
        result = query(ven, ':CONF:TLS:OUTP OFF');
        extracted = venturi_extract_result(result);
        if(~strcmp(extracted,'Off'))
            error(result);
        end
    end
end

