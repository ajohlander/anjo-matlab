function [hsf,ionMat,t] = plot_hia_subspin(h,tint,scInd,plotMode,colLim)
%ANJO.PLOT_HIA_SUBSPIN plots data from HIA in phase space density [s^3km^-6].
%   [hsf,ionMat,t] = ANJO.PLOT_HIA_SUBSPIN(h,tint,scInd,mode,colLim) plots
%   HIA data in phase space density. Returns data in ionMat and time vector
%   t. Input tint is the time interval for the data, scInd is the
%   spacecraft number (1 or 3) and colLim is the limits of the colorbar.
%
%   mode:
%       'default'   - returns full 4-D matrix.
%       'energy'    - integrates over polar angle
%
%   See also: ANJO.GET_HIA_DATA
%
%   ONLY WORKS FOR SUBSPIN DATA

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
caxis(colLim)
ylabel(h,'$\log{E}$ [eV]','FontSize',16,'interpreter','latex')
legStr = ['C',num2str(scInd),'\_CP\_CIS-HIA\_HS\_MAG\_IONS\_PSD'];
irf_legend(h,{legStr},[0.02, 0.05])

if(hideXLabel)
    set(h,'XTickLabel',[])
else
    irf_timeaxis(h)
end


end

