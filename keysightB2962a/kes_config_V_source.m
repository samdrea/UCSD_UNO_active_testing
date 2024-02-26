function kes_config_V_source(kes, I_compliance)
% Change Keithley to voltage source and set I compliance (in mA)
    % - kes: keithley VISA object (see kes_start())
    % - I_compliance: compliance current (mA)
    fwrite(kes, 'Output off');              % Output OFF before any config

    %fwrite(kes,'rout:term front');          % Use front terminal
    %fwrite(kes,'syst:rsen OFF');            % 2-wire connections

    % fwrite(kes,'sens:func "CURR"');         % Measure function: current
    fwrite(kes,'sour:func:mode volt');           % Source function: voltage

    %fwrite(kes,'sour:VOLT:Mode fix')        % Fixed voltage source mode

    %fwrite(kes,'sens:curr:range:auto 1');   % Current range: automatic
    %fwrite(kes,'sour:volt:range:auto 1');   % Voltage range: automatic
    % Set compliance
    I_compliance_mA = I_compliance/1000;
    fwrite(kes, "sens:curr:prot " + num2str(I_compliance_mA));
end

