function agilent_set_range(agi, range, channel)
    % Turn off power autorange
    agilent_autorange(agi, false);
    % Set Power Range
    str = sprintf('sens2:chan%d:pow:rang %f', channel, range);
    fwrite(agi, str);
end

