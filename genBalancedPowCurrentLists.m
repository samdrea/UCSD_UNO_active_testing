function [I_inc_out, I_dec_out] = genBalancedPowCurrentLists(...
    resistance, ... % resistance of load (ohms)
    P_tot, ... % P_inc + P_dec = P_tot (W) throughout sweep. Max power on any heater cannot exceed this.
    P_range, ... % if P_range = P_tot, sweeps go from 0 to P_tot and P_tot to 0. if a lesser number, pick lists such that P_tot is still satisfied
    start_num, ... % number of points to dwell at start
    P_num, ... % number of power ramp points
    end_num) % number of points to dwell at end
    if(P_range > P_tot)
        error("P_range (%f) greater than P_tot (%f)!", P_range, P_tot);
    end
    P_diff = linspace(-P_range,P_range,P_num);
    P_inc = P_tot/2 + P_diff/2;
    P_dec = P_tot/2 - P_diff/2;
    I_inc = sqrt(P_inc/resistance);
    I_dec = sqrt(P_dec/resistance);
    start_ones = []; end_ones = [];
    if(start_num > 0)
        start_ones = ones(1,start_num);
    end
    if(end_num > 0)
        end_ones = ones(1,end_num);
    end
    I_inc_out = [I_inc(1)*start_ones, I_inc, I_inc(end)*end_ones];
    I_dec_out = [I_dec(1)*start_ones, I_dec, I_dec(end)*end_ones];
end