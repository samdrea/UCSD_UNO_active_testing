function agilent_autorange(agi, doAutorange)
    % turn on/off power meter autoranging - applies to both detectors
    if(doAutorange)
        writeString = 'sens2:chan1:pow:rang:auto 1';
    else
        writeString = 'sens2:chan1:pow:rang:auto 0';
    end
    fwrite(agi, writeString);
    fwrite(agi, '*WAI');
end

