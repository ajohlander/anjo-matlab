function [out] = fix_x_label(AX)
%ANJO.FIX_X_LABEL Tweaks axes to properly display x-label.
%
%   ANJO.FIX_X_LABEL Changes position of axes to make sure x-label is not
%   hidden
%
%   ANJO.FIX_X_LABEL(AX) Acts on specified axes AX instead of current axes.
%
%   H = ANJO.FIX_X_LABEL Also returns label handle H.
%
%   Possibly works sometimes... maybe.

if(nargin == 0)
    AX = gca;
end

hxl = AX.XLabel;

%set units of label to normalized
hxl.Units = 'normalized';
AX.Units = 'normalized';

axPos = AX.Position;

r0 = axPos(1:2);
rPrime = hxl.Extent(1:2);
r = r0+rPrime;

h = hxl.Extent(4);

D = r0(2);
lTop = r(2)+h;

d = D-lTop;

D = h+d;

axPos(2) = D;
AX.Position = axPos;

hxl = AX.XLabel;
%hxl.Position

if(nargout == 1)
    out = hxl;
end

end