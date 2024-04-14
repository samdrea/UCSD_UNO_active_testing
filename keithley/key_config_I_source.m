function key_config_I_source(key, V_compliance)
% Change Keithley to current source and set V compliance
    % - key: keithley VISA object (see key_start())
    % - V_compliance: compliance voltage (V)
    fwrite(key, 'Output off');              % Output OFF before any config
    
    fwrite(key,'rout:term front');          % Use front terminal
    %fwrite(key,'syst:rsen OFF');            % 2-wire connections

    fwrite(key,'sens:func "volt"');         % Measure function: voltage
    fwrite(key,'sour:func curr');           % Source function: current

    fwrite(key,'sour:CURR:Mode fix')        % Fixed current source mode

    fwrite(key,'sens:volt:range:auto 1');   % Voltage range: automatic
    fwrite(key,'sour:curr:range:auto 1');   % Current range: automatic
    % Set compliance
    fwrite(key, "sens:volt:prot " + num2str(V_compliance));
end

