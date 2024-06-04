function N = agilent_setup_for_santec(agi, N, range)
    % TODO allow custom int time for max sensitivity
    % range: power range in dBm, will be rounded to nearest 10 (-60 to 10)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Sensor Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Input trigger Mode:single measurement, giving one sample per trigger
    str = upper('trig2:chan1:inp sme');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set Power Units: Watt
    str = upper('sens2:chan1:pow:unit 1');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Turn off power autorange
    str = upper('sens2:chan1:pow:rang:auto 0');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set Power Range
    str = upper(['sens2:chan1:pow:rang ' num2str(range) 'dbm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');

    %Stop any previous logging
    fwrite(agi,'sens2:chan1:func:stat logg,stop');
    fwrite(agi, '*WAI');
    
    %Expected number of triggers and Averaging time
    str = upper(['sens2:chan1:func:par:logg ' num2str(N) ',100 us']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set input trigger mode
    str = upper('sens2:chan1:func:stat logg,star');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
end
