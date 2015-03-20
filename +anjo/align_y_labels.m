function [] = align_y_labels(h)
%ANJO.ALIGN_Y_LABELS Fixes the x-position of the y-labels
%   ANJO.ALIGN_Y_LABELS(h) aligns y labels for all panels in the vector h.


minXPos = +Inf;

if(anjo.is_new_matlab())
    for i = 1:length(h)
        lH = h(i).YLabel;
        lH.Units = 'Normalized';
        pos = lH.Position;
        xPos = pos(1);
    
        if(xPos<minXPos)
            minXPos = xPos;
        end
    end
    for i = 1:length(h)
        lH = h(i).YLabel;
        lH.Units = 'Normalized';
        pos = lH.Position;
        lH.Position = [minXPos,pos(2),pos(3)];
    end
    
else
    for i = 1:length(h)
        lH = get(h(i),'YLabel');
        pos = get(lH,'Position');
        xPos = pos(1);
        if(xPos<minXPos)
            minXPos = xPos;
        end
    end
    
    for i = 1:length(h)
        lH = get(h(i),'YLabel');
        pos = get(lH,'Position');
        set(lH,'Position',[minXPos,pos(2),pos(3)]);
    end
    
end
end

