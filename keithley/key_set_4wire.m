function key_set_4wire(key, do4Wire)
    % set keithley to either 2 wire (False) or 4 wire (true)
    setting = "";
    if(do4Wire)
        setting = "on";
    else
        setting = "off";
    end
    fwrite(key,"syst:rsen " + setting);
end

