function [tOut] = fast_date(tIn,showMilliSeconds)
%ANJO.FAST_DATE Returns a date string
%   tOut = ANJO.FAST_DATE(tIn, showMilliSeconds) returns the date of tIn,
%   which is in Unix time. showMilliSeconds is a boolean.
%   tOut = ANJO.FAST_DATE(tIn) shows milliseconds by default.

if(nargin == 1)
    showMilliSeconds = 1; %Default
end

if (showMilliSeconds ~= 1 && showMilliSeconds ~= 0)
    showMilliSeconds = 1;
end

if showMilliSeconds
    tOut = datestr(tIn/(3600*24) + datenum([1970 01 01 00 00 00]),'yyyy-mm-dd HH:MM:SS.FFF');
else
    tOut = datestr(tIn/(3600*24) + datenum([1970 01 01 00 00 00]),'yyyy-mm-dd HH:MM:SS');
end

end

