function key_show_error_queue(key)
    % Query Keithley for errors
    query(key, "syst:err:all?")
end

