function kes_config_I_source(kes, V_compliance, channel)
% Change to current source and set V compliance
    if(~exist('channel','var'))
        channel = 1; % default to channel 1
    end
    kes_output(kes, false); % turn output off for safety
    % Source function: current
    fwrite(kes, sprintf('sour%d:func:mode curr', channel)); 
    % compliance voltage, V
    fwrite(kes, sprintf("sens%d:volt:prot %f", channel, V_compliance)); 
end

