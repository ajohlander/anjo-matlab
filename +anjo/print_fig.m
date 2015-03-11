function [out] = print_fig(x1,x2,x3)
%ANJO.PRINT_FIG Exports figure to file.
%   ANJO.PRINT_FIG(fileName) exports current figure to a .eps with name
%   fileName.
%   ANJO.PRINT_FIG(figNum,fileName) exports figure with number
%   figNum to a .eps named fileName.
%   ANJO.PRINT_FIG(fileName,fileType) exports current figure to a file named
%   fileName with format fileType.
%   ANJO.PRINT_FIG(figNum,fileName,fileType) exports figure with number
%   figNum to a file named fileName with format fileType.
%
%   Only works for .eps at this time!!
%
%   TODO: 
%       -Enable figure handle input instead of figure number.
%       -Fix for .pdf



figNum = 0;
fileType = 'eps';

if(nargin == 1)         % only name
    fileName = x1;
elseif(nargin == 2)
    if(ischar(x1))      % name and type
        fileName = x1;
        fileType = x2;
    else                % number and name
        figNum = x1;
        fileName = x2;
    end
elseif(nargin == 3)     % number, name and type
    figNum = x1;
    fileName = x2;
    fileType = x3;
end

if(figNum == 0) %never assigned
    f = gcf;
    figNum = f.Number;
end

fileStr = [fileName,'.',fileType];
% make current figure
figure(figNum) 

if(nargout == 1)
    out = gcf;
end

% Exporting the figure
print(gcf,'-depsc','-loose','-painters',fileStr) 


end