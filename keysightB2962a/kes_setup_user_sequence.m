function kes_setup_user_sequence(...
            kes, ... % keysight VISA object
            channel, ... % output channel, 1 or 2
            supply, ... % supply type 'voltage' or 'current'
            level_list, ... % list of voltage (V) or current (A) levels
            time_step, ... % how long each point should last
            compliance) % compliance current (A) or voltage (V) (corresponding to supply type)
    % setup power supply do do user-defined arbitrary output sequence
    % current or voltage allowed
    % channel 1 or channel 2 allowed
    % TODO add support for trigger array? (BOST command, 4-122)
    
    % check channel input
    if(channel ~= 1 && channel ~= 2)
        error("Invalid channel id (%d), must be 1 or 2", channel);
    end
    % check supply input
    if(supply == 'voltage')
        compl_string = 'current';
    elseif(supply == 'current')
        compl_string = 'voltage';
    else
        error("Invalid supply type (%s), must be 'voltage' or 'current'", supply);
    end
    
    % compliance current
    fwrite(kes,sprintf('sens%d:%s:prot %f', channel, compl_string, compliance));
    
    % check level_list input
    if(length(level_list) > 100000)
        error("Level list too long (%d pts), must be <= 100,000", length(level_list));
    end
    % check time step input
    if(time_step < 1e-5 || time_step > 1e3)
        error("Time step (%f sec) out of range, must be within [1e-5, 1e3]", time_step);
    end

    % put power supply in specified source mode
    fwrite(kes,sprintf('sour%d:func:mode %s', channel, supply));
    % arbitrary waveform gen mode
    fwrite(kes,sprintf('sour%d:%s:mode arb', channel, supply));
    % UDEF waveform type
    fwrite(kes,sprintf('sour%d:arb:func udef', channel));
    % set time step
    fwrite(kes, sprintf('sour%d:arb:%s:udef:time %f', channel, supply, time_step));
    
    % send array of pts
    % need to break this up into chunks dictated by output buffer size
    buffer_size = kes.OutputBufferSize;
    % command to start new array of data in power supply
    start_commend_prefix = sprintf('sour%d:arb:%s:udef:lev ', channel, supply);
    % command to append to data array in power supply
    append_command_prefix = sprintf('sour%d:arb:%s:udef:lev:app ', channel, supply);
    % number of bytes we have to squeeze values into, give 10 bytes of
    % wiggle room
    room_for_values = buffer_size - length(append_command_prefix) - 10; 
    value_format = '%.6e,'; % format spec for values to send
    bytes_per_value = length(sprintf(value_format,0));
    values_per_block = floor(room_for_values/bytes_per_value);
    value_idx = 1;
    while(value_idx <= length(level_list))
        this_end_block = value_idx + values_per_block - 1;
        if(this_end_block > length(level_list))
            this_block = level_list(value_idx:end);
        else
            this_block = level_list(value_idx:this_end_block);
        end
        % generate string of values
        this_block_str = sprintf(value_format, this_block);
        % remove trailing comma
        this_block_str = this_block_str(1:end-1);
        % send VISA command with prefix and values
        if(value_idx == 1)
            this_command_prefix = start_commend_prefix;
        else
            this_command_prefix = append_command_prefix;
        end
        fwrite(kes, sprintf('%s %s', this_command_prefix, this_block_str));
        value_idx = value_idx + values_per_block;
    end
    % verify all the data got sent, just check # of pts (if it got right
    % number, those points are probably correct)
    num_pts_query = sprintf(':SOUR%d:ARB:%s:UDEF:LEV:POIN?', channel, supply);
    received_num_pts = str2double(query(kes, num_pts_query));
    if(received_num_pts ~= length(level_list))
        error(['Number of points received by power supply (%d) does not ' ...
            'match number of points we sent (%d)! If this happens more ' ...
            'than once in a row, something is very wrong... '], ...
            received_num_pts, length(level_list));
    end

    
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
    % turn on trigger
    fwrite(kes,':TRIG1:TRAN:TOUT:STAT 1');
    % choose output port
    fwrite(kes,':TRIG1:TRAN:TOUT:SIGN EXT2');
    % configure that output port for the task
    fwrite(kes, ":dig:ext2:func TOUT"); % output trigger
    fwrite(kes, ":dig:ext2:pol POS"); % positive polarity
    fwrite(kes, ":dig:ext2:tout:pos BEF"); % trigger before event
    fwrite(kes, ":dig:ext2:tout:widt max"); % max trigger width
    fwrite(kes, ":dig:ext2:tout:type EDGE"); % edge type trigger
    % wait until previous commands are processed
    fwrite(kes,'*WAI');
    % enable output
    %fwrite(kes,'outp%d 1');
    %fwrite(kes,'*WAI');
end