function laser_set_basic_params(laser, power, lambda)
% Set some basic params for laser and power meter 
% Software alternative to pressing buttons on laser
% Doesn't include triggering, logging, sweep settings etc.

    % laser power (dbM)
    str = upper(['sour0:pow ',num2str(power),'dBm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % laser wavelength (nm)

    str = upper(['sour0:wav ',num2str(lambda),'nm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');

end

