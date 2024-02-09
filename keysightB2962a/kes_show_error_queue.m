function kes_show_error_queue(kes)
    % Query Keithley for errors, print them in console
    % - kes: keithley VISA object (see kes_start())
    query(kes, "syst:err:all?")
end

