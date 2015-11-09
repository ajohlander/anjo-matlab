function out = yy(ax,option)
%ANJO.YY Double y-axes, compatible with irf_plot and surfaces.
%   
%   ax = ANJO.YY(AX,...) Returns 1x2 vector of axes given an axes handle
%   AX. ax(1) = AX;
%
%   ANJO.YY(ax) Where ax is a 1x2 vector of axes handles. Updates the axis
%   to look good. Updates colors and colorbar.
%
%   ANJO.YY(...,option) Performs a specific action.
%   
%   options:
%       'color' -   updates the an y-axis to the same color as the 'first'
%                   line. Is done by default.
%       'freeze' -  freezes the two overlapping axes to allow for zooming
%                   in x and y for both axes. Destroys zooming link between
%                   irf panels.
%
%   Example: 
%       figure;
%       ax = anjo.yy;
%       pcolor(ax(1),magic(6))
%       x = 0:0.1:2*pi;
%       plot(ax(2),x,sin(x),'r')
%       % Always do two calls
%       anjo.yy(ax)

if nargin == 0
    ax = gca;
    option = 'none';
elseif nargin == 1
    if ishandle(ax)
        option = 'none';
    else
        option = ax;
        ax = gca;
    end
end

if strcmpi(option,'none')
    if length(ax) == 1;
        irf.log('w','Initiating double y axis plot.')
        
        % set current figure
        f = ax.Parent;
        figure(f);
        
        ax2 = axes;
        AX = [ax,ax2];
        
        anjo.yy(AX)
        
    elseif length(ax) == 2
        irf.log('w','Linking and aligning axes.')
        
        AX = ax;
        
        AX(2).Position = AX(1).Position;
        linkaxes(AX,'x');
        %linkaxes(AX,'y');
        
        AX(2).Color = 'none';
        AX(2).XTick = [];
        AX(2).XTickLabel = '';
        AX(2).XLabel.String = '';
        AX(2).YAxisLocation = 'right';
        
        % Set position for any y-labels on AX(2). Hack code.
        hl = AX(2).YLabel;
        l_pos = hl.Position;
        ax_pos = AX(1).Position;
        dx = ax_pos(1)-l_pos(1);
        hl.Position(1) = sum(ax_pos([1,3]))+dx-0.02;
        
        
        % Check for colorbar in AX(1). AX(2) should not be a surface.
        % Because Matlab is perfect, the parent of a colorbar is a Figure (why
        % would it ever be an Axes?). Therfore a ugly hack using position is needed.
        hcb = findall(gcf,'Type','ColorBar'); % returns a vector of colorbars.
        ax_ypos = AX(1).Position(2)+AX(1).Position(4)/2;
        n = length(hcb);
        for i = 1:n
            cb_ypos = hcb(i).Position(2)+hcb(i).Position(4)/2;
            if abs(ax_ypos-cb_ypos)<0.008 %Arbitrary value
                irf.log('w','Changing position of axes and colorbar')
                for j = 1:2
                    AX(j).Position(3) = AX(j).Position(3)-0.11;
                end
                hcb(i).Position(1) = hcb(i).Position(1)+0.11;
                break;
            end
        end
        
        % Color by default
        anjo.yy(AX,'color')
        
        set(gcf, 'CurrentAxes',AX(1))
    end
    
else
    switch option
        case 'freeze'
            if length(ax) == 1
                error('Must be two axes for option freeze.');
            end
            irf.log('w','Freezes two axes to each other')
            % THIS PART DESTROYS THE LINK BETWEEN PANELS.
            % Allow for zooming in y and x simultaniously. Three lines "borrowed"
            % from plotyy.
            % Each axes must be able to point to its peer. Rather than use
            % an instance property, we will use appdata for speed.
            setappdata(ax(1),'graphicsPlotyyPeer',ax(2));
            setappdata(ax(2),'graphicsPlotyyPeer',ax(1));
            matlab.graphics.internal.PlotYYListenerManager(ax(1),ax(2));
            
            % Supresses warnings when zooming. Like a pro.
            warning('off','MATLAB:uitools:uimode:callbackerror')
            
        case 'color'
            irf.log('w','Colors y-axis and label.')
            hline = findall(ax(end).Children,'Type','Line');
            if isempty(hline) 
                irf.log('w','Found no line')
            else
                col = hline(1).Color;
                ax(end).YAxis.Color = col;
            end
    end
end

if nargout == 1
    out = AX;
end

end