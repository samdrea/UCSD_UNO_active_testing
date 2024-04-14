function kes_set_4wire(kes, do4Wire)
    % set keithley to either 2 wire (False) or 4 wire (true)
    setting = "";
    if(do4Wire)
        setting = "on";
    else
        setting = "off";
    end
    fwrite(kes,"sens:rem " + setting);
end