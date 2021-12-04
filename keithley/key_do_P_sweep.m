function [measured_V, measured_I, measured_P] = key_do_P_sweep(...
    key, p_min, p_max, p_step, v_comp, i_comp, settle_time, function_handle)
% Do a uniform-step power sweep with the specified parameters
% This was created because uniform-step voltage or current sweeps yield
% very non-idea temperature sampling (uniform voltage sampling -> quadratic
% power sampling ~ closer to quadratic temperature sampling than linear
% temperature sampling)
% We actually just do a voltage sweep with a square-root sampling
% However in order to get the right power we just grab the impedance of the
% load on the power supply at the beginning and then pre-generate the
% voltage points
% As we measure the *actual* power through the load and don't rely on what
% we're predicting, this gets us close enough to the uniform sampling we
% desire
    % - key: keithley VISA object (see key_start())
    % - p_min: (mW)  minimum current of sweep
    % - p_max: (mA) maximum current of sweep
    % - p_step: (mA) current step of sweep
    % - v_comp: (V) when calculating voltage points, we won't exceed this value
    % - i_comp: (mA) compliance current of voltage source throughout experiment
    % - settle_time: time (in seconds) to pause after each voltage point on the
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
    
    % Turn Keithley output off
    key_output(key, false);
    
    % Get resistance of load (keithley selects test current automatically,
    % but it should never be above 1mA)
    resistance = key_measure_resistance(key);
    
    power_list = p_min:p_step:p_max;
    % units: V = sqrt(ohm*W) -> V = sqrt(ohm*mW/1000)
    voltage_list = sqrt(resistance*(power_list/1000));
    voltage_number = length(voltage_list);
    
    max_voltage = max(voltage_list);
    est_max_current = 1000*max(voltage_list)/resistance;
    disp(['Measured resistance (ohm): ' num2str(resistance,4)]);
    
    if(resistance > 1e6)
        error('Load resistance greater than 1 Mohm, likely open circuit.');
    end
    
    disp(['Max voltage to be applied (voltage): ' num2str(max_voltage,4)]);
    if(max_voltage > v_comp)
        warning("Specified power sweep will exceed compliance voltage!");
        disp(['Compliance voltage: ' num2str(v_comp,4)]);
        disp('If you continue, the output (and therefore the power) will be limited by the compliance voltage.');
        response = input('Continue (y/n)','s');
        if(response ~= 'y')
            return
        end 
    end
  
    disp(['Estimated max current (mA): ' num2str(est_max_current,4)]);
    
    if((est_max_current) > i_comp)
        warning("Specified power sweep might exceed compliance current!");
        disp(['Compliance current: ' num2str(i_comp)]);
        disp('If you continue, the output (and therefore the power) will be limited by the compliance current.');
        response = input('Continue (y/n)','s');
        if(response ~= 'y')
            return
        end
    end
    
    % Configure Keithley as a voltage source with the provided compliance
    key_config_V_source(key, i_comp);
    
    % Set Keithley voltage to 0 for safety before turning on
    key_set_V(key, 0);
    
    % Turn Keithley output on
    key_output(key, true);
    
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
        key_set_V(key, voltage_point);
        
        if(settle_time)
            % Pause for the specified settle time
            pause(settle_time);
        end
        
        % Measure actual voltage and current after settling
        [measured_V(v_index), measured_I(v_index)] = key_measure(key);
        
        % check if we're hitting i compliance
        if(measured_I(v_index) >= i_comp)
            warning('Measured current equals current compliance, current compliance likely triggered!');
        end
        
        % Call user-provided handle
        function_handle();
        
        % Update user with progress
        disp(['Measurement ' num2str(v_index) ' of ' ...
            num2str(voltage_number) ' complete (' ...
            num2str(measured_V(v_index)*measured_I(v_index),3) ' mW).']);
    end
    
    % Turn Keithley output off
    key_output(key, false);

    % Calculate actual power (in mW) off of all the individual measurements
    measured_P = measured_I.*measured_V;
    
end

