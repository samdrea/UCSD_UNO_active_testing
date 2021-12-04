function key_config_V_source(key, I_compliance)
% Change Keithley to voltage source and set I compliance (in mA)
    % - key: keithley VISA object (see key_start())
    % - I_compliance: compliance current (mA)
    fwrite(key, 'Output off');              % Output OFF before any config

    fwrite(key,'rout:term front');          % Use front terminal
    fwrite(key,'syst:rsen OFF');            % 2-wire connections

    fwrite(key,'sens:func "CURR"');         % Measure function: current
    fwrite(key,'sour:func VOLT');           % Source function: voltage

    fwrite(key,'sour:VOLT:Mode fix')        % Fixed voltage source mode

    fwrite(key,'sens:curr:range:auto 1');   % Current range: automatic
    fwrite(key,'sour:volt:range:auto 1');   % Voltage range: automatic
    % Set compliance
    I_compliance_mA = I_compliance/1000;
    fwrite(key, "sens:curr:prot " + num2str(I_compliance_mA));
end

