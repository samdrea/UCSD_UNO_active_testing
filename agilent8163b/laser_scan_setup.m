function N = laser_scan_setup(laser,sweep_speed,sweep_step,power,lambda_i,lambda_f,range)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Laser Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Trigger from laser goes to power meter
    fwrite(laser, 'trig:conf loop');
    fwrite(laser, '*WAI');
    
    % power unit: dBm
    fwrite(laser, 'outp1:pow:un dbm');
    fwrite(laser, '*WAI');
    
    % laser power
    str = upper(['sour1:pow ',num2str(power),'dBm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');

    % sweep mode: continuous
    fwrite(laser, 'sour1:wav:swe:mode cont');
    fwrite(laser, '*WAI');
    
    % sweep speed [nm/s]
    str = upper(['sour1:wav:swe:speed ',num2str(sweep_speed),'E-9']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');

    % start wavelength
    str = upper(['sour1:wav:swe:start ',num2str(lambda_i),'E-9']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');

    % stop wavelength
    str = upper(['sour1:wav:swe:stop ',num2str(lambda_f),'E-9']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % sweep step:
    str = upper(['sour1:wav:swe:step ',num2str(sweep_step),'E-9']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % amplitude modulation off (required to allow LLoging)
    fwrite(laser, 'sour1:am:stat off');
    fwrite(laser, '*WAI');
    
    % Output Trigger mode: step finished 
    fwrite(laser, 'trig1:outp stf');
    fwrite(laser, '*WAI'); 
    
    % Input Trigger mode: start sweep 
    fwrite(laser, 'trig1:inp sws');
    fwrite(laser, '*WAI');   
    
    % Laser channel: High output
%     str = upper('output0:path low');
%     str = upper('output0:path high');
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');
    
    % Laser goes to start wavelength
    str = upper(['sour1:wav ',num2str(lambda_i),'nm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % Laser output ON
    str = upper('sour1:pow:stat 1');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % Lambda logging ON: records the exact wavelength of a tunable laser
    % use upper('sour1:read:data? llog') to read this data
    fwrite(laser, 'sour1:wav:swe:llog 1');
    fwrite(laser, '*WAI');
    
    % N = number of sweep points
    N = query(laser,'sour1:wav:swe:exp?','%s','%d');
    fwrite(laser, '*WAI');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Sensor Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Input trigger Mode:single measurement, giving one sample per trigger
    str = upper('trig2:chan1:inp sme');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Set Power Units: Watt
    str = upper('sens2:chan1:pow:unit 1');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Turn off power autorange
    str = upper('sens2:chan1:pow:rang:auto 0');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Set Power Range
    str = upper(['sens2:chan1:pow:rang ' num2str(range) 'dbm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Set Sensor Wavelength
    str = upper(['sens2:chan1:pow:wav ' num2str(+lambda_i) 'nm']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Stop any previous logging
    fwrite(laser,'sens2:chan1:func:stat logg,stop');
    fwrite(laser, '*WAI');
    
    %Expected number of triggers and Averaging time
    str = upper(['sens2:chan1:func:par:logg ' num2str(N) ',100us']);
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    %Set input trigger mode
    str = upper('sens2:chan1:func:stat logg,star');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
end
