function out = venturi_extract_result(strIn, elementNum)
    % extract returned value from venturi VISA return string
    if ~exist('elementNum', 'var')
        elementNum = 2;
    end
    splitStr = split(strIn);
    out = splitStr{elementNum};
end

