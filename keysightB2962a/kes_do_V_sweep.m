function [measured_V, measured_I, measured_P] = kes_do_V_sweep(...
    kes, v_min, v_max, v_step, v_comp, i_comp, settle_time, function_handle)
% Do a voltage sweep with the specified parameters
    % - kes: keithley VISA object (see kes_start())
    % - v_min: (V)  minimum voltage of sweep
    % - v_max: (V) maximum voltage of sweep
    % - v_step: (V) voltage step of sweep
    % - i_comp: (mA) compliance current of voltage source throughout experiment
    % - settle_time: time (in seconds) to pause after each voltage point on the
    %       sweep prior to taking any further actions
    % - function_handle: function to be executed at each voltage point in the
    %       sweep (after settle time). This argument is meant to provide a way
    %       to perform ANY measurement you'd like at each voltage step. This
    %       function will not be called with any arguments, and the return
    %       value(s) will not be accessible.
% This allows a single voltage sweep function to be used for many types of
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
    
    % display warning (but don't necessarily exit) if max volt > compliance
    if(v_max > v_comp)
        warning("Specified voltage sweep will exceed compliance voltage!");
        disp(['Max voltage: ' num2str(v_max,4)]);
        disp(['Compliance voltage: ' num2str(v_comp,4)]);
        disp('If you continue, the output will be limited by the compliance voltage.');
        response = input('Continue (y/n)','s');
        if(response ~= 'y')
            return
        end 
    end
    
    voltage_list = v_min:v_step:v_max;
    voltage_number = length(voltage_list);

    % Turn Keithley output off
    kes_output(kes, false);
    
    % Configure Keithley as a voltage source with the provided compliance
    kes_config_V_source(kes, i_comp);
    
    % Set Keithley voltage to 0 for safety before turning on
    kes_set_V(kes, 0);
    
    % Turn Keithley output on
    kes_output(kes, true);
    
    % Pre-generate a couple save arrays
    measured_V = zeros(length(voltage_list), 1);
    measured_I = zeros(length(voltage_list), 1);
    
    for v_index = 1:voltage_number
        % Get voltage, respecting compliance
        voltage_point = voltage_list(v_index);
        if(voltage_point > v_comp)
            warning(['Voltage compliance triggered! Compliance voltage '...
                num2str(v_comp) ' V used instead of requested voltage '...
                num2str(voltage_point) 'V']);
            voltage_point = v_comp;
        end
        % Set Keithley to voltage point
        kes_set_V(kes, voltage_point);
        
        if(settle_time)
            % Pause for the specified settle time
            pause(settle_time);
        end
        
        % Measure actual voltage and current after settling
        [measured_V(v_index), measured_I(v_index)] = kes_measure(kes);
        
        % check if we're hitting i compliance
        if(measured_I(v_index) >= i_comp)
            warning('Measured current equals current compliance, current compliance likely triggered!');
        end
        
        % Call user-provided handle
        function_handle();
        
        % Update user with progress
        disp(['Measurement ' num2str(v_index) ' of ' ...
            num2str(voltage_number) ' complete (' ...
            num2str(measured_V(v_index),3) ' V).']);
    end
    
    % Turn Keithley output off
    kes_output(kes, false);

    % Calculate actual power (in mW) off of all the individual measurements
    measured_P = measured_I.*measured_V;
    
end

