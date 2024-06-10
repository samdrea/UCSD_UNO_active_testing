function [I_inc, I_dec] = genBalancedPowCurrentLists(...
    resistance, ... % resistance of load (ohms)
    P_tot, ... % P_inc + P_dec = P_tot (W) throughout sweep. Max power on any heater cannot exceed this.
    P_range, ... % if P_range = P_tot, sweeps go from 0 to P_tot and P_tot to 0. if a lesser number, pick lists such that P_tot is still satisfied
    P_num) % number of power points
    if(P_range > P_tot)
        error("P_range (%f) greater than P_tot (%f)!", P_range, P_tot);
    end
    P_diff = linspace(-P_range,P_range,P_num);
    P_inc = P_tot/2 + P_diff/2;
    P_dec = P_tot/2 - P_diff/2;
    I_inc = sqrt(P_inc/resistance);
    I_dec = sqrt(P_dec/resistance);
end