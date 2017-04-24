function [] = panel_span(ax,yl)
%PANEL_SPAN Summary of this function goes here
%   Detailed explanation goes here

N = numel(ax);

h = diff(yl)/N;

for k = 1:N
    ax(k).Position(2) = yl(1)+(N-k)*h;
    ax(k).Position(4) = h;
end

end

