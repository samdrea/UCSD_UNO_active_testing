function [measured_V, measured_I, measured_P] = kes_do_I_list(...
    kes, i_list, v_comp, i_comp, settle_time, function_handle)
% Do a voltage sweep with the specified parameters
    % - kes: keithley VISA object (see kes_start())
    % - i_list: (mA) list of current points to sample
    % - v_comp: (V) compliance voltage of current source throughout experiment
    % - settle_time: time (in seconds) to pause after each current point on the
    %       sweep prior to taking any further actions
    % - function_handle: function to be executed at each current point in the
    %       sweep (after settle time). This argument is meant to provide a way
    %       to perform ANY measurement you'd like at each current step. This
    %       function will not be called with any arguments, and the return
    %       value(s) will not be accessible.
% This allows a single current sweep function to be used for many types of
    % experiments, and allows swapping out optical equipment with different
    % interfaces in a modular way.
% However, it also means the function handle you pass has to handle
    % everything in a self-contained way, including saving the output to a data
    % structure etc. This is best accomplished simply by configuring the
    % function to store its results in global variables
% Returns:
    % - measured_V: vector of actual voltages measured at each sample (V)
    % - measured_I: vector of actual current measured at each sample (mA)
    % - measured_V: vector of actual power measured at each sample (mW)
    
    % display warning (but don't necessarily exit) if max curr > compliance
    i_max = max(i_list);
    if(i_max > i_comp)
        warning("Specified current sweep will exceed compliance current!");
        disp(['Max current: ' num2str(i_max,4)]);
        disp(['Compliance current: ' num2str(i_comp,4)]);
        disp('If you continue, the output will be limited by the compliance current.');
        response = input('Continue (y/n)','s');
        if(response ~= 'y')
            return
        end 
    end
    
    current_list = i_list; % legacy
    current_number = length(current_list);

    % Turn Keithley output off
    kes_output(kes, false);
    
    % Configure Keithley as a current source with the provided compliance
    kes_config_I_source(kes, v_comp);
    
    % Set Keithley current to 0 for safety before turning on
    kes_set_I(kes, 0);
    
    % Turn Keithley output on
    kes_output(kes, true);
    
    % Pre-generate a couple save arrays
    measured_V = zeros(length(current_list), 1);
    measured_I = zeros(length(current_list), 1);
    
    for i_index = 1:current_number
        % Get current, respecting compliance
        current_point = current_list(i_index);
        if(current_point > i_comp)
            warning(['Current compliance triggered! Compliance current '...
                num2str(i_comp) ' mA used instead of requested current '...
                num2str(current_point) 'mA']);
            current_point = i_comp;
        end
        
        % Set Keithley to current point
        kes_set_I(kes, current_point);
        
        if(settle_time)
            % Pause for the specified settle time
            pause(settle_time);
        end
        
        % Measure actual voltage and current after settling
        [measured_V(i_index), measured_I(i_index)] = kes_measure(kes);
        
        % check if we're hitting v compliance
        if(measured_V(i_index) >= v_comp)
            warning('Measured voltage equals voltage compliance, voltage compliance likely triggered!');
        end
        
        % Call user-provided handle
        function_handle();
        
        % Update user with progress
        disp(['Measurement ' num2str(i_index) ' of ' ...
            num2str(current_number) ' complete (' ...
            num2str(measured_I(i_index),3) ' mA).']);
    end
    
    % Turn Keithley output off
    kes_output(kes, false);

    % Calculate actual power (in mW) off of all the individual measurements
    measured_P = measured_I.*measured_V;
    
end

