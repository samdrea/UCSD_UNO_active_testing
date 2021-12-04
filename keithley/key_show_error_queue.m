function key_show_error_queue(key)
    % Query Keithley for errors, print them in console
    % - key: keithley VISA object (see key_start())
    query(key, "syst:err:all?")
end

