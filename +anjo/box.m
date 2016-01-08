function [out] = box(AX,opt)
%ANJO.BOX Draws a box around axes.
%   Good for spectrograms

if nargin == 0
    AX = gca;
elseif nargin == 1
    if ishandle(AX(1))
        opt = 'toggle';
    else
        opt = AX;
    end
end

n = length(AX);

hbox = gobjects(1,n);
has_box = 0; % 0: no box, 1: box, 2: invisible box

for i = 1:n
    ax = AX(i);
    hl = findall(ax.Children,'Type','Line');
    
    for j = 1:length(hl)
        if isfield(hl(j).UserData,'anjotype') && strcmpi(hl(j).UserData.anjotype,'box')
            hbox(i) = hl(j);
            if strcmpi(hl(j).Visible,'on')
                has_box = 1;
            else
                has_box = 2;
            end
        end
    end
end

if strcmpi(opt,'toggle')
    if has_box == 0
        opt = 'on';
    elseif has_box == 1
        opt = 'off';
    elseif has_box == 2
        opt = 'show';
    end
end

if strcmpi(opt,'on') && has_box == 2
    opt = 'show';
end

switch opt
    case 'on'
        
        for i = 1:n
            ax = AX(i);
            is_held = ishold(ax);
            if ~is_held
                hold(ax,'on')
            end
            xlim = ax.XLim;
            ylim = ax.YLim;
            
            x = [xlim(1),xlim(1),xlim(2),xlim(2),xlim(1)];
            y = [ylim(1),ylim(2),ylim(2),ylim(1),ylim(1)];
            
            hbox = plot(ax,x,y,'k');
            hbox.UserData.anjotype = 'box';
            
            if ~is_held
                hold(ax,'off')
            end
        end
        
    case 'off'
        for i = 1:n
            hbox(i).Visible = 'off';
        end
        
    case 'show'
        for i = 1:n
            hbox(i).Visible = 'on';
        end
        
    case 'update'
        delete(hbox)
        box(AX,'on')
end

if nargout == 1
    out = hbox;
else
    
end

