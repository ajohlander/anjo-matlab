function [H,h] = afigure(subNum,figSize)
%ANJO.AFIGURE Quick way to call irf_plot
%   ANJO.AFIGURE(subNum) Initiate figure with number of panels subNum. Size of
%   figure is set to 10x7 cm.
%   ANJO.AFIGURE(subNum,figSize) Declare size of figure with a vector 
%   figSize = [width, height] in centimeters.
%   [H,h] = ANJO.AFIGURE(...) Returns figure handle H and vector of handles for
%   the panels h.
%
%   See also: IRF_PLOT

if(nargin == 1)
    figSize = [10,7];
end

%Initiate figure
H = irf_plot(subNum,'newfigure');
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
    %H(i).FontSize = 20;
end
% 
% for i = 1:subNum
%     %H(i).FontSize = 20;
% end


end

