function [varargout] = fig(varargin)
%FIG Like afigure but with no relation to irf_plot
%   Detailed explanation goes here


if nargin == 0
    N = 1;
else
    N = varargin{1};
end

irf.log('w','Initiating new plain figure')
f = figure;
ax = gobjects(1,N);
for k = 1:N
    ax(k) = axes('Parent',f);
    ax(k).Box = 'on';
    ax(k).FontSize = 15;
end
anjo.panel_span(ax,[0.13,0.95])
f.Color = 'w';






if nargout > 0
    varargout{1} = ax;
    if nargout > 1
        varargout{2} = f;
    end
end






end

