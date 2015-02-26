function [eField] = plot_3d_e_field(h,x1,scInd)
%ANJO.PLOT_3D_E_FIELD plot 3D EFW data in ISR2.
%   ANJO.PLOT_3D_E_FIELD(h,tint,scInd) plots 3D electric field data from EFW
%   data in ISR2 during the time interval tint and for s/c number scInd =
%   1,2,3,4.
%   eField = ANJO.PLOT_3D_E_FIELD(h,tint,scInd) also returns the eField.
%
%   See also: ANJO.GET_3D_E_FIELD, ANJO.PLOT_3D_B_FIELD, ANJO.GET_3D_B_FIELD


hideXLabel = isequal(get(h,'XTickLabel'),[]);

if(nargin == 2) %E-field input!
    eField = x1;
    tint = [min(eField(:,1)),max(eField(:,1))];
else
    tint = x1;
    eField = get_3d_e_field(tint,scInd);
end

irf_plot(h,eField);

legLD = [0.02,0.06];
irf_legend(h,{'E_{x}','E_{y}','E_{z}'},legLD);

ylabel('$E$ [mVm$^{-1}$]','FontSize',16,'interpreter','latex')

irf_zoom(h,'x',tint) 

if(hideXLabel)
    set(h,'XTickLabel',[])
end

end