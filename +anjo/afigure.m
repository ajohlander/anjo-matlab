function [h,f] = afigure(subNum,figSize)
%ANJO.AFIGURE Quick way to call irf_plot
%   ANJO.AFIGURE(subNum) initiates figure with number of panels subNum. Size of
%   figure is set to 10x7 cm.
%   ANJO.AFIGURE(subNum,figSize) declare size of figure with a vector
%   figSize = [width, height] in centimeters.
%   h = ANJO.AFIGURE(...) returns vector of axes for the panels h
%   [h,f] = ANJO.AFIGURE(...) also returns figure f.
%
%   See also: IRF_PLOT


if(nargin == 1)
    figSize = [10,7];
elseif(nargin == 0)
    figSize = [10,7];
    subNum = 1;
end

if(anjo.is_new_matlab()) % Awesome new code
    
    % Initiate figure
    h = irf_plot(subNum,'newfigure');
    f = h.Parent;
    
    % Set parameters
    f.PaperUnits = 'centimeters';
    xSize = figSize(1); ySize = figSize(2);
    xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
    f.PaperPosition = [xLeft yTop xSize ySize];
    f.Position = [10 10 xSize*50 ySize*50];
    f.PaperPositionMode = 'auto';
    
    for i = 1:subNum
        if(i ~= subNum)
            h(i).XTickLabel = '';
        end
    end
    
else
    
    %Initiate figure
    irf_plot(subNum,'newfigure');
    set(gcf,'PaperUnits','centimeters')
    xSize = figSize(1); ySize = figSize(2);
    xLeft = (21-xSize)/2; yTop = (30-ySize)/2;
    set(gcf,'PaperPosition',[xLeft yTop xSize ySize])
    set(gcf,'Position',[10 10 xSize*50 ySize*50])
    set(gcf,'paperpositionmode','auto') % to get the same printing as on screen
    
    
    h = zeros(1,subNum);
    for i = 1:subNum
        h(i) = irf_panel(num2str(i));
        if(i ~= subNum)
            set(h(i),'XTickLabel',[])
        end
    end
    f = get(h(1),'Parent');
end

end

