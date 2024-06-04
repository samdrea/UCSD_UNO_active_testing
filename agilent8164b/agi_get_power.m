function [power1, power2]  = agi_get_power(agi)
% Just triggers and returns a single value from power meter 2.1
% Does not change any settings, that must be done beforehand
% Value returned is in W from laser so convert to mW too
    power1 = 1000*str2double(query(agi, "read2:chan1:pow?"));
    power2 = 1000*str2double(query(agi, "read2:chan2:pow?"));
end

