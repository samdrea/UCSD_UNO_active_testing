%% Function to trigger wavelength sweep on Agilent 8164b, after configured using laser_scan_setup
function [lambda,pow] = laser_scan(laser,N)
    % N: number of points in sweep (returned by laser_scan_setup)
    % SIDENOTE: COMMAND TO READ ERROR QUEUE: query(laser, "syst:err?")
    
    % Calculate buffer lengths for when we get data later
    % The data is prefaced with an ASCII number giving # of bytes
    % Therefore we need to account for the length of this decimal ASCII
    % number when we read out the string
    % we have 4 bytes per data point for transmission (single float)
    Ly = length(num2str(4*N)); 
    % we have 8 bytes per data point for lambda logging (double)
    Lx = length(num2str(8*N));
    % calc x and y total buffer sizes knowing buffer is of the form
    % '#1' + [num of data bytes, formatted in decimal ASCII] + [data bytes]
    yBufferSize = 2+Ly+4*N; %Bytes;
    xBufferSize = 2+Lx+8*N; %Bytes;
    
    % Laser sweep ON
    str = upper('sour1:wav:swe 1');
    fwrite(laser, str);
    fwrite(laser, '*WAI')
    
    % Wait until sweep is started
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
    
    
    % Check logging stability is COMPLETE before we read out data
    
    i = 0;
    while i<=60
        str = upper('sens2:chan1:func:stat?');
        quer = query(laser,str,'%s','%s');
        if strcmp(quer,'LOGGING_STABILITY,COMPLETE')
            % Read out power meter data
            fwrite(laser,'sens2:chan1:func:res?');
            y = fread(laser,[1,yBufferSize],'uint8');
            break;
        end
        if i==10
            y = 'ERROR';
            query(laser,'sens2:chan1:func:stat?')
        end
        i=i+1;
        pause(1);
    end
    yh = dec2hex(y);
    if(char(y(1)) ~= '#')
        disp('# Error')
        pow = 'Error';
    end
    if(char(y(1)) == '#')
        pow = zeros(1,N);
        for i = 1:N
            j = 2+Ly+4*i;
            % convert strange byte order arrays to single floats
            ydec = [yh(j,:) yh(j-1,:) yh(j-2,:) yh(j-3,:)];
            hexbits = uint32(hex2dec(ydec));
            pow(i) = typecast(hexbits, 'single');
        end
    end

    %fwrite(laser,'sens2:chan1:func:stat logg,stop');
    
    
    %Laser stability: Wait for 10 secs to give Lambda data
    
    i = 0;
    while i<=60
        str = upper('sour1:wav:swe:flag?');
        if query(laser,str,'%s','%d')~= 0
            %Lambda data
            fwrite(laser,'sour1:read:data? llog');
            x = fread(laser,[1,xBufferSize],'uint8');
            break;
        end
        if i==10
            x = 'ERROR';
        end
        i=i+1;
        pause(1);
    end
    
    xh = dec2hex(x);
    if(char(x(1)) ~= '#')
        disp('# Error')
        pow = 'Error';
    end
    if(char(x(1)) == '#')
        lambda = zeros(1,N);
        for i = 1:N
            j = 2+Lx+8*i;
         
            xdec = [xh(j,:) xh(j-1,:) xh(j-2,:) xh(j-3,:) xh(j-4,:) xh(j-5,:) xh(j-6,:) xh(j-7,:)];
            hexbits = uint64(hex2dec(xdec));
            lambda(i) = typecast(hexbits, 'double');
        end
    end
  
    % Laser sweep OFF
    str = upper('sour1:wav:swe 0');
    fwrite(laser, str);
    fwrite(laser, '*WAI')

    % Laser output OFF
    str = upper('sour1:pow:stat 0');
    fwrite(laser, str);
    fwrite(laser, '*WAI');
    
    % Put input trigger back to ignore so that screen auto updates
    fwrite(laser, 'trig2:inp ign');
    fwrite(laser, '*WAI');   
end

    