function [out] = box(AX,opt)
%ANJO.BOX Draws a box around axes.
%   Good for spectrograms
%
%   ANJO.BOX Toggles box on the current axes.
%
%   ANJO.BOX(AX) Toggles box on specified array of axes.
%
%   ANJO.BOX(...,opt) Specify option:
%                       'toggle'    -   toggle
%                       'on'/'off'  -   on/off
%                       'update'    -   make new box after zoom
%
% TODO: Fix bug where subplots move when toggling box.

if nargin == 0
    AX = gca;
    opt = 'toggle';
elseif nargin == 1
    if ishandle(AX(1))
        opt = 'toggle';
    else
        opt = AX;
    end
end

n = numel(AX);

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
            xl = ax.XLim;
            yl = ax.YLim;
            
            x = [xl(1),xl(1),xl(2),xl(2),xl(1)];
            y = [yl(1),yl(2),yl(2),yl(1),yl(1)];
            
            hbox = plot(ax,x,y,'k');
            hbox.UserData.anjotype = 'box';
            
            uistack(hbox,'top')
            
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
        anjo.box(AX,'on')
end

if nargout == 1
    out = hbox;
else
    
end

