function [isNew] = is_new_matlab()
% ANJO.IS_NEW_MATLAB Checks if new plot system is to be used
%   isNew = ANJO.IS_NEW_MATLAB() returns 1 if the current version of matlab
%   is 2014b or later. Otherwise returns 0.

ver = version('-release');
year = str2double(ver(3:4));
let = ver(5);
if(year >= 15)
    isNew = 1;
elseif(year < 14)
    isNew = 0;
else            % year == 14
    switch let
        case 'a'
            isNew = 0;
        case 'b'
            isNew = 1;
    end
end