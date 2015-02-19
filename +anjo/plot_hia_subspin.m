function [hsf,ionMat,t] = plot_hia_subspin(h,tint,scInd,plotMode,colLim)
%PLOT_HIA_SUBSPIN Summary of this function goes here
%   Detailed explanation goes here


tintData = [tint(1)-12,tint(2)+12];
[ionMat,t] = anjo.get_hia_data(tintData,scInd,plotMode);
[~,~,etab] = anjo.get_hia_values('all');

hideXLabel = isequal(get(h,'XTickLabel'),[]);


switch plotMode
    case 'energy'
        hsf = surf(h,t,log10(etab),log10(ionMat'));
        
        ylim(h,[0,max(log10(etab))])
        
end

set(hsf,'EdgeColor','none')
view(h,2)
xlim(h,tint)

ylabel(h,'$\log{E}$ [eV]','FontSize',16,'interpreter','latex')
legStr = ['C',num2str(scInd),'\_CP\_CIS-HIA\_HS\_MAG\_IONS\_PSD'];
irf_legend(h,{legStr},[0.02, 0.05])

if(hideXLabel)
    set(h,'XTickLabel',[])
else
    irf_timeaxis(h)
end


end

