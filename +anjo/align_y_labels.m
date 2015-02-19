function [] = align_y_labels(h)
%ANJO.ALIGN_Y_LABELS fixes the x-position of the y-labels
%   Does not really work now

minXPos = 0;

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

