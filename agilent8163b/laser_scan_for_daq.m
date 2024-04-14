function [x, y, H_fig] = laser_scan_for_daq(laser,ds, lambda_i,lambda_f, power, sweep_speed)
%[x, y] = laser_scan(laser,ds, source, lambda_i,lambda_f, power)
%
%   Measures transmission spectrum using Agilent 81980A
% 
%input arguments:
%         laser: laser device handler
%         ds: DAQ handler
%         source: 1 or 2 (specifies the laser channel)
%         lambda_i: start wavelength in [nm]
%         lambda_f: stop wavelength in [nm]
%         power: laser output power in [dBm]% 
% output arguments:
%         x: wavelength vector
%         y: transmission vector
%***********************************************************************************
% laser power
%     str = upper(['sour1:pow ',num2str(power),'dBm']);
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');
% 
% %% start wavelength
%     str = upper(['sour1:wav:swe:start ',num2str(lambda_i),'E-9']);
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');
% 
% %% stop wavelength
%     str = upper(['sour1:wav:swe:stop ',num2str(lambda_f),'E-9']);
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');
%% Sets DAQ for aquisition
daq_time = daq_set(ds, lambda_i, lambda_f, sweep_speed);

%% ********************************************************************
%  Run laser sweep
%  ********************************************************************
%%
%     % Laser goes to start wavelength
%     str = upper(['sour1:wav ',num2str(lambda_i),'nm']);
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');
% 
%     % Laser output ON
%     str = upper('sour1:pow:stat 1');
%     fwrite(laser, str);
%     fwrite(laser, '*WAI');

    str = upper('sour1:wav:swe 1');
    fwrite(laser, str);
    fwrite(laser, '*WAI')
    % pause(3);
        i = 0;
    while i<=10
        str = upper('sour1:wav:swe:flag?');
        if query(laser,str,'%s','%d')== 1
            str = upper('sour1:wav:swe:soft');
            fwrite(laser, str);
            fwrite(laser, '*WAI');
            break;
        end
        if i==10
            disp('Sweep start ERROR');
        end
        i=i+1;
        pause(1);
    end
    
    

% % Laser output ON
% str = upper(['sour1:pow:stat 1']);
% fwrite(laser, str);
% fwrite(laser, '*WAI');

% Aquiring data from DAQ
% Aquiring data from DAQ
[data,time] = ds.startForeground;  % start session in Foreground

% Laser goes to start wavelength
str = upper(['sour1:wav ',num2str(lambda_i),'nm']);
fwrite(laser, str);
fwrite(laser, '*WAI');

%stop(ds);
%startForeground(ds);        % stops any previous acquisition and starts a new one
%[data,time] = getdata(ds); % measured analog inputs and associated time
%stop(ds);   % stops the acquisition
%pause(1);

% Laser output OFF
%str = upper(['sour',num2str(source),':pow:stat 0']);
%fwrite(laser, str);
%fwrite(laser, '*WAI');

%% ***************************************************************************************
%
% Plots 
H_fig = figure(100);

% ------------------------------------------------------------------------
% Measured transmission and trigger
% Detects rising and falling edges on trigger signal
trig = data(:,1);           % trigger channel; each rising edge corresponds to a 1nm step
trig_edge = diff(trig);     % find trigger edges
[edgeup, edgedown]=peakdet(trig_edge, 1, time(1:end-1));

close(100);       % Prevents consecutive measurements to be shown in the same figure
figure(100);
% Plot daq data
h_sp1 = subplot(2,1,1);
[AX,H1,H2] = plotyy(time,data(:,1),time,data(:,2)); hold on;
linkaxes([AX(1) AX(2)],'x');
plot(edgeup(:,1),edgeup(:,2),'Marker','*','Color','r');xlabel('Time (secs)');
ylabel('Voltage');
xlim([0 daq_time]);

%% ---------------------------------------------------------------------------
% Transmission (y) vs Wavelength (x)
% y = Transmission
index_i = find(time == edgeup(1,1));     % index of first edge up
index_f = find(time == edgeup(end,1));   % index of last edge up
y = data(index_i:index_f,2);             % transmission signal from first edgeup to last edgeup

%%
% x = Wavelength
Time = [];                         % Time vector of all edges up
for ii=1:length(edgeup)
t = time(find(time == edgeup(ii,1)));
Time = [Time,t];
end

Time = Time';
W = linspace(lambda_i, lambda_f, length(Time))';  % Wavelength vector corresponding to trigger points 
t = time(index_i:index_f,1);
x = interp1(Time,W,t);

% Plot Transmission vs Wavelength
h_sp2 = subplot(2,1,2);
plot(x,y); hold on;
grid minor;
xlim([lambda_i lambda_f]);
xlabel('Wavelength (nm)');
ylabel('Transmission (a. u.)');

end