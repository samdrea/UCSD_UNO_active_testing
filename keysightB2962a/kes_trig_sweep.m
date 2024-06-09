function kes_trig_sweep(kes)
    % triggers sweeps on BOTH channels!
    % TODO make this a setting - simply switch between the following
    % arguments:
    % (@1) for 1 only
    % (@2) for 2 only
    % (@1,2) for
    fwrite(kes ,'init (@1,2)');
end

