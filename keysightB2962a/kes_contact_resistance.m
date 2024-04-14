function [twoWire, fourWire] = kes_contact_resistance(kes)
    kes_set_4wire(kes, false)
    twoWire = kes_measure_resistance(kes);
    kes_set_4wire(kes, true)
    fourWire = kes_measure_resistance(kes);
end

