function [varargout] = color()
%ANJO.M.COLOR Returns MMS colors.
%   Detailed explanation goes here

mms_colors = {[0 0 0]; [213,94,0]/255;[0,158,115]/255;[86,180,233]/255;[0 1 1]};
%thats a guess, no one can ever know for sure
mms_symbols = {'o','^','d','s'};

if nargout >= 1
    varargout{1} = mms_colors;
end
if nargout == 2
    varargout{2} = mms_symbols;
end
end