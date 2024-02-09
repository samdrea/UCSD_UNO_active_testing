function resistance = kes_measure_resistance(kes)
% Performs auto 2-wire measurement and returns resistance (in ohms)
% Warning! Keithley automatically selects the current used for this
% Current through load can be as high as 10mA (only for low resistance
% loads)
    % - kes: keithley VISA object (see kes_start())

    % set to ohm function
    fwrite(kes, 'sens:func "res" ');
    
    % auto ohm mode
    % fwrite(kes, 'sens:res:mode AUTO');
    
    % turn on, take measurement, turn off
    kes_output(kes, true);
    result_string = query(kes, ':meas:res?');
    kes_output(kes, false);
    
    % turn auto-ohm mode back off
    % fwrite(kes, 'sens:res:mode MAN');
    
    % result_split = regexp(result_string,',','split');       % splits data separted by ','
    
    resistance = str2double(result_string);
end

