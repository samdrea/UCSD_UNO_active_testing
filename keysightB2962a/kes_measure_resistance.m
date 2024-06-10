function resistance = kes_measure_resistance(kes, channel)
    if(~exist('channel','var'))
        channel = 1; % default to channel 1
    end
    % turn on, take measurement, turn off
%     kes_output(kes, true);
%     fwrite(kes, '*WAI?'); 
    % enable resistance measurement
    fwrite(kes, sprintf('SENS%d:FUNC "RES"', channel));
    % Keysight turns on by itself, actually
    result_string = query(kes, sprintf(':MEAS:RES? (@%d)', channel));
    kes_output(kes, false);
    resistance = str2double(result_string);
end

