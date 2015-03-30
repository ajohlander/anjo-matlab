function [out] = label(varargin)
%ANJO.LABEL   Adds label to axis
%
%   ANJO.LABEL(AX,...) sets label for specified axes handle.
%   
%   ANJO.LABEL(label) sets y-label for current axes.    
%
%   ANJO.LABEL('x', label) sets x-label. 'z' for z-axis. 
%
%   H = ANJO.LABEL(...) also returns label handle H.
%
%  Uses LaTeX interperter and font size 16.


%% Input parameters
% default values
AX = gca;
axis = 'y';

textStr = varargin{1};
if(nargin == 1) % Only string
    textStr = varargin{1};
elseif(nargin == 2) % handle-string or axis/string
    if(ischar(varargin{1})) % axis
        axis = varargin{1};
    elseif(isvalid(varargin{1}))
        AX = varargin{1};
    end
    textStr = varargin{2};
elseif(nargin == 3)
    AX = varargin{1};
    axis = varargin{2};
    textStr = varargin{3};
end

%% Gets label handle
switch axis
    case 'x'
        hLabel = AX.XLabel;
    case 'y'
        hLabel = AX.YLabel;
    case 'z'
        hLabel = AX.ZLabel;
    otherwise
        error('Unknown axis')
end

%% Sets label properties
hLabel.String = textStr;
hLabel.FontSize = 16;
hLabel.Interpreter = 'latex';

if(nargout == 1)
    out = hLabel;
end

end