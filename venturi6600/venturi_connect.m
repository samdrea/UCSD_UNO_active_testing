function ven = venturi_connect()
    ven = visa('agilent','GPIB1::4::INSTR');
    ven.InputBufferSize = 5000;   % set input buffer
    ven.OutputBufferSize = 5000;  % set output buffer
    ven.Timeout=10; % set maximum waiting time [s]  
    fopen(ven); % open communication channel
    disp(query(ven, '*IDN?')); % enquires equipment info
end

