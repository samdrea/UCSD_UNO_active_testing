function laser = start_laser() 
    % hard-coded address
    laser = visa('ni','TCPIP0::169.254.188.145::inst0::INSTR');
    laser.InputBufferSize = 5000000;   % set input buffer
    laser.OutputBufferSize = 5000000;  % set output buffer
    laser.Timeout=20; % set maximum waiting time [s]  
    fopen(laser); % open communication channel
    query(laser, '*IDN?') % enquires equipment info
    disp('Laser created');
end