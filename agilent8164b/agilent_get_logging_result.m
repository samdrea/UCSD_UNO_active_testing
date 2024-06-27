function [channel1, channel2] = agilent_get_logging_result(agi)
    % this function assumes we've checked LOGGING_STABILITY, COMPLETE
    % already
    
    % do an initial query to know # of bytes to read
    queryResult = query(agi,'sens2:chan1:func:res?');
    if(char(queryResult(1)) ~= '#') %
        error("Logging result did not start with a #:" + dataIn);
    end
    % number of digits in following number of bytes
    numDigits = str2num(queryResult(2));
    % number of bytes comprising result
    numBytes = str2num(queryResult(3:3+numDigits-1));
    % now, we can do an fread to get those bytes - can't do a query as some
    % of the bytes may be same as EOF which ends query
    % must add a few bytes to the beginning since the beginning of the
    % buffer has that stuff we just used above
    extraBytes = 2 + numDigits;
    channel1 = getChannelResults(agi, 1, extraBytes, numBytes);
    channel2 = getChannelResults(agi, 2, extraBytes, numBytes);
end


function readingArray = getChannelResults(agi, channel, extraBytes, numBytes)
    % channel must be 1 or 2 (number)
    writeString = sprintf("sens2:chan%d:func:res?", channel);
    fwrite(agi,writeString);
    dataIn = fread(agi,extraBytes+numBytes,'uint8');
    % power meter readings have 4 bytes
    bytesPerReading = 4;
    numReadings = numBytes/bytesPerReading;
    readingArray = zeros(1,numReadings);
    for readingIdx = 1:numReadings
        byteIdx = extraBytes+bytesPerReading*(readingIdx-1);
        theseBytes = dataIn(byteIdx+1:byteIdx+4);
        readingArray(readingIdx) = typecast(uint8(theseBytes), 'single');
    end
    
%     y = dataIn;
%     N = numReadings;
%     yh = dec2hex(y);
%     Ly = length(num2str(4*N));
%     if(char(y(1)) == '#')
%         pow = zeros(1,N);
%         for i = 1:N
%             j = 2+Ly+4*i;
%             % convert strange byte order arrays to single floats
%             ydec = [yh(j,:) yh(j-1,:) yh(j-2,:) yh(j-3,:)];
%             hexbits = uint32(hex2dec(ydec));
%             pow(i) = typecast(hexbits, 'single');
%         end
%     end
end



