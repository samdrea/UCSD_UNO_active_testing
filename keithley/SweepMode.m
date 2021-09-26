classdef SweepMode
    % Simple enum to switch between sweep modes on Keithley code
   enumeration
      voltage, % Voltage source sweep with uniform voltage steps
      current, % Current source sweep with uniform current steps
      power % Voltage source step with uniform power steps, using load 
        % impedance measured prior to sweep
   end
end