function [eField] = plot_3d_e_field(x1,x2,scInd)
%ANJO.PLOT_3D_E_FIELD plot 3D EFW data in ISR2.
%   ANJO.PLOT_3D_E_FIELD(h,tint,scInd) plots 3D electric field data from EFW
%   data in ISR2 during the time interval tint and for s/c number scInd =
%   1,2,3,4.
%   ANJO.PLOT_3D_E_FIELD(h,eField) plots the input E-field with the
%   correct plot mode.
%   ANJO.PLOT_3D_E_FIELD(eField) Initiates a new figure and plots the
%   input E-field.
%   eField = ANJO.PLOT_3D_E_FIELD(...) also returns the eField.
%
%   See also: ANJO.GET_3D_E_FIELD, ANJO.PLOT_3D_B_FIELD, 
%   ANJO.GET_3D_B_FIELD


if(nargin == 1) %E-field input!
    h = anjo.afigure(1);
    eField = x1;
    tint = [min(eField(:,1)),max(eField(:,1))];
elseif(nargin == 2)
    h = x1;
    eField = x2;
    tint = [min(eField(:,1)),max(eField(:,1))];
else
    tint = x2;
    eField = anjo.get_3d_e_field(tint,scInd);
end

hideXLabel = isequal(get(h,'XTickLabel'),[]);
irf_plot(h,eField);

legLD = [0.02,0.06];
irf_legend(h,{'E_{x}','E_{y}','E_{z}'},legLD);

ylabel(h,'$E$ [mVm$^{-1}$]','FontSize',16,'interpreter','latex')

irf_zoom(h,'x',tint)

if(hideXLabel)
    set(h,'XTickLabel',[])
end

end