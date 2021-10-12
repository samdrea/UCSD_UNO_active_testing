function plot_heater_sweep_spectra(spectra_results, heater_power, laser_power)
% plot heater sweep spectra w/ color coded lines
% spectra_results: 2 x [# of lambda samples] x [# of heater samples] matrix
% heater_power: array of heater power at each heater sample
% laser_power: laser power in dBm
    laser_power_mW = (10^(laser_power/10));
    figure;
    hold on
    for i = 1:size(spectra_results,3)
        name = [num2str(heater_power(i),4) ' mW'];
        color = getColor(i,size(spectra_results,3));
        plot(spectra_results(1,:,i),10*log10(spectra_results(2,:,i)./laser_power_mW),...
            "DisplayName", name, ...
            "Color", color, ...
            "LineWidth", 2);
    end
    hold off;
    legend();
    xlabel("Wavelength");
    ylabel("Insertion loss (dB)");
    function color = getColor(index, size)
        % simple blue-to-red LUT
        startHue = 0.7;
        endHue = 1;
        startVal = 0.7;
        endVal = 1;
        hue = startHue + (index-1)*(endHue-startHue)/(size-1);
        val = startVal + (index-1)*(endVal-startVal)/(size-1);
        color = hsv2rgb(hue,1,val);
    end
end

