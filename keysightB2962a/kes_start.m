function kes = kes_start()
% KEY_START Connect to Keithley 2400 over GPIB via VISA
% - key: VISA object returned for communication to/from Keithley
% This function only needs to be called once, and the same VISA object can
% then be referenced in all future key_**** function calls     
    kes = visa('ni','TCPIP0::169.254.5.2::inst0::INSTR');
    kes.InputBufferSize = 5000;   % set input buffer
    kes.OutputBufferSize = 5000;  % set output buffer
    kes.Timeout=10; % set maximum waiting time [s]  
    fopen(kes) % open communication channel
    disp(query(kes, '*IDN?')); % enquires equipment info
end

