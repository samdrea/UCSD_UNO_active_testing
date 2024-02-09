function [sweep_speed] = laser_set_sweep_for_daq(laser)
%[] = laser_set(laser)
%
%   Set laser modules Agilent 81980A and 81940A parameters% 
%   input arguments:
%         laser: laser device handler
%% ***********************************************************************************

% power unit: dBm
fwrite(laser, 'outp0:pow:un dbm');
fwrite(laser, '*WAI');

% sweep mode: continuous
fwrite(laser, 'sour0:wav:swe:mode cont');
fwrite(laser, '*WAI');

% sweep speed [nm/s]
sweep_speed = 5;
str = upper(['sour0:wav:swe:speed ',num2str(sweep_speed),'E-9']);
fwrite(laser, str);
fwrite(laser, '*WAI');

% cycles: 1
fwrite(laser, 'sour0:wav:swe:cycl 1');
fwrite(laser, '*WAI');

% amplitude modulation off (required to allow LLoging)
fwrite(laser, 'sour0:am:stat off');
fwrite(laser, '*WAI');

% Trigger mode: step finished 
fwrite(laser, 'trig0:outp stf');
fwrite(laser, '*WAI');

% trigger step:
sweep_step = 0.1;   % [nm]
str = upper(['sour0:wav:swe:step ',num2str(sweep_step),'E-9']);
fwrite(laser, str);
fwrite(laser, '*WAI');

% Lambda logging ON: records the exact wavelength of a tunable laser
% use upper('sour',,num2str(source),':read:data?') to read this data
fwrite(laser, 'sour0:wav:swe:llog on');
fwrite(laser, '*WAI');

end