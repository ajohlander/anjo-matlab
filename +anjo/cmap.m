function [cmap] = cmap(varargin)
%ANJO.CMAP Custom colormap.
%
%   c = ANJO.CMAP Returns custom colormap that goes from light to dark.
%   Similar to irfu "standard" but with more yellow.
%   
%   c = ANJO.CMAP(colorMapName) Returns special colormap.
%
%   c = ANJO.CMAP(color) Returns monochromatic colormap from white to
%   black with specified color.
%
%   Colormap Names:
%       'standard'  -   similar to irf_colormap
%       'anjo'      -   orange and blue
%   
%   Colors:
%       'red'
%       'green'
%       'blue'
%       'yellow'
%       'orange'
%       'lime'
%       'gray'
%
%   Examples:  colormap(AX,ANJO.CMAP('blue'));
%
%   See also: IRF_COLORMAP


if(nargin == 0)
    cMapMode = 'standard';
else
    cMapMode = varargin{1};
end
    

switch lower(cMapMode) % Special colormaps
    case 'standard'
        
        c = [255,255,255;...
            043,255,255;...
            000,255,000;...
            255,255,000;...
            255,255,000;...
            255,000,000;...
            000,000,255]/255;
        
    case 'anjo'
        c = [1,1,1;...
            1,0.7,0;...
            0,0,0.8;...
            0,0,0];
        
    otherwise % Single color

        switch lower(cMapMode)
            case 'red'
                cMiddle = [1,0,0];
            case 'green'
                cMiddle = [0,1,0];
            case 'blue'
                cMiddle = [0,0,1];
            case 'yellow'
                cMiddle = [1,1,0];
            case 'orange'
                cMiddle = [1,0.7,0];
            case 'lime'
                cMiddle = [0.5,1,0];
            case 'gray'
                cMiddle = [0.5,0.5,0.5];
            case 'grey'
                cMiddle = [0.5,0.5,0.5];
            otherwise
                error('Unknown color')
        end
        
        c = [1,1,1;cMiddle;0,0,0];
        
end

cN = size(c,1);
x = linspace(1,64,cN);
cmap = zeros(64,3);
        
for i = 1:64
    cmap(i,:) = interp1(x,c,i);
end

end
