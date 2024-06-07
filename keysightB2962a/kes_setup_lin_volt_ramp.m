function kes_setup_lin_volt_ramp(...
            kes, ... % keysight VISA object
            channel, ... % output channel, 1 or 2
            count, ... % repeat ramp this many times
            start_time, ... % begin ramp this long after trigger (s)
            rtime, ... % take this long to ramp up (s)
            end_time, ... % stay at end voltage for this long (s)
            Vi, ... % start voltage (V)
            Vf, ... % end voltage (V)
            cur_cmpl) % compliance current (I) CONFIRM
    % set parameters for linear voltage ramp on specified channel
    % put power supply in voltage mode
    fwrite(kes,sprintf('sour%d:func:mode volt', channel));
    % arbitrary waveform gen mode
    fwrite(kes,sprintf('sour%d:volt:mode arb', channel));
    % ramp waveform
    fwrite(kes,sprintf('sour%d:arb:func ramp', channel));
    % ramp repeat
    fwrite(kes, sprintf('sour%d:arb:coun %d', channel, count));
    % start time
    fwrite(kes, sprintf('sour%d:arb:volt:ramp:star:time %f', channel, start_time));
    % end time
    fwrite(kes, sprintf('sour%d:arb:volt:ramp:end:time %f', channel, end_time));
    % ramp time
    fwrite(kes, sprintf('sour%d:arb:volt:ramp:rtim %f', channel, rtime));
    % start voltage
    fwrite(kes, sprintf('sour%d:arb:volt:ramp:star:lev %f', channel, Vi));
    % end voltage
    fwrite(kes, sprintf('sour%d:arb:volt:ramp:end:lev %f', channel, Vf));
    % compliance current
    fwrite(kes,sprintf('sens%d:curr:prot %f', channel, cur_cmpl));
    
    % enable front panel display
    fwrite(kes,'disp:enab 1')
    % display only channel 1 (legacy)
    % fwrite(kes,'disp:view sing1')
    
    % set trigger count to 1, we don't need to trigger same thing mult
    % times
    fwrite(kes,'trig:coun 1');
    % use automatic internal trigger to "intelligently" pick what trigger
    % we want
    fwrite(kes,'trig:sour aint');
    fwrite(kes,':TRIG1:TRAN:TOUT:STAT 1');
    fwrite(kes,':TRIG1:TRAN:TOUT:SIGN EXT2');
    % wait until previous commands are processed
    fwrite(kes,'*WAI');
    % enable output
    %fwrite(kes,'outp%d 1');
    %fwrite(kes,'*WAI');
end