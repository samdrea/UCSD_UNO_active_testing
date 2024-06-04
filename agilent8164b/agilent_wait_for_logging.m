function didFinish = agilent_wait_for_logging(agi, maxWaitTime)
    % poke Agilent until sweep is finished, return true if it finished in
    % specified time
    % if sweep is complete, we get this:
    if ~exist('maxWaitTime', 'var')
        maxWaitTime = 30;
    end
    completeString = ['LOGGING_STABILITY,COMPLETE' newline()]; 
    % if sweep is in progress, we get this:
    progressString = ['LOGGING_STABILITY,PROGRESS' newline()];
    % no need to be fancy, just check and pause every second
    didFinish = false;
    for waitIdx = 1:maxWaitTime
        thisResponse = query(agi, ":SENS2:CHAN1:FUNC:STAT?");
        fwrite(agi, '*WAI');
        if(strcmp(thisResponse, completeString))
            disp('Agilent complete!');
            didFinish = true;
            return
        elseif(strcmp(thisResponse, progressString))
            if(waitIdx == 1)
                disp('Agilent power meter logging in progress...');
            else
                fprintf('.'); % dot dot dot loading
                if(mod(waitIdx,10) == 0)
                    fprintf('\n');
                end
            end
        else
            % we got some other response, error and print it
            error(['Unexpected response from Agilent: ' thisResponse]);
        end
        pause(1);
    end
end