function [varargout] = color(option)
%ANJO.M.COLOR Returns MMS colors.
%   Detailed explanation goes here

if nargin == 0
    option = 'cell';
end
    
c1 = [0 0 0];
c2 = [213,94,0]/255;
c3 = [0,158,115]/255;
c4 = [86,180,233]/255;
c5 = [0 1 1];

switch lower(option)
    case 'cell'
        mms_colors = {c1;c2;c3;c4;c5};
    case 'mat'
        mms_colors = [c1;c2;c3;c4;c5];
    otherwise
        error('unknown option.')
end
%thats a guess, no one can ever know for sure
mms_symbols = {'s','d','o','v'};


varargout{1} = mms_colors;
if nargout == 2
    varargout{2} = mms_symbols;
end
end