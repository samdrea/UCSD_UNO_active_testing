function resistance = key_measure_resistance(key)
% Performs auto 2-wire measurement and returns resistance (in ohms)
% Warning! Keithley automatically selects the current used for this
% Current through load can be as high as 10mA (only for low resistance
% loads)
    % - key: keithley VISA object (see key_start())

    % set to ohm function
    fwrite(key, 'sens:func "res" ');
    
    % auto ohm mode
    % fwrite(key, 'sens:res:mode AUTO');
    
    % turn on, take measurement, turn off
    key_output(key, true);
    result_string = query(key, 'read?'); % voltage, current, resistance, time, status
    key_output(key, false);
    
    % turn auto-ohm mode back off
    % fwrite(key, 'sens:res:mode MAN');
    
    result_split = regexp(result_string,',','split');       % splits data separted by ','
    
    resistance = str2double(result_split{3});
end

