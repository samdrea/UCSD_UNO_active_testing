function [twoWire, fourWire] = key_contact_resistance(key)
    key_set_4wire(key, false)
    twoWire = key_measure_resistance(key);
    key_set_4wire(key, true)
    fourWire = key_measure_resistance(key);
end

