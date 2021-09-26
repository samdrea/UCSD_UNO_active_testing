function key = key_start()
% KEY_START Connect to Keithley 2400 over GPIB via VISA
    key = visa('agilent','GPIB0::24::INSTR');
    key.InputBufferSize = 5000;   % set input buffer
    key.OutputBufferSize = 5000;  % set output buffer
    key.Timeout=10; % set maximum waiting time [s]  
    fopen(key); % open communication channel
    query(key, '*IDN?') % enquires equipment info
    disp('key created');
end

