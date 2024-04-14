function laser_output(laser, doTurnOn)
% Function to turn laser output on/off
    if(doTurnOn)
        % Laser output ON
        str = upper('sour1:pow:stat 1');
        fwrite(laser, str);
        fwrite(laser, '*WAI');
    else
        % Laser output OFF
        str = upper('sour1:pow:stat 0');
        fwrite(laser, str);
        fwrite(laser, '*WAI');
    end
end

