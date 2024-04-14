function power = laser_get_power(laser)
% Just triggers and returns a single value from power meter 2.1
% Does not change any settings, that must be done beforehand
% Value returned is in W from laser so convert to mW too
    power = 1000*str2double(query(laser, "read2:chan1:pow?"));
end

