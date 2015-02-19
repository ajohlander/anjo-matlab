function [eField] = plot_3d_e_field(h,tint,scInd)
%PLOT_3D_E_FIELD plot 3D EFW data in ISR2.
%   PLOT_3D_E_FIELD(h,tint,scInd) plots 3D electric field data from EFW
%   data in ISR2 during the time interval tint and for s/c number scInd =
%   1,2,3,4.
%   eField = PLOT_3D_E_FIELD(h,tint,scInd) also returns the eField.


%I'm a rocket man


if(scInd == 1 || scInd == 2 || scInd == 3 || scInd == 4)
    dataStr = ['E_Vec_xyz_ISR2__C',num2str(scInd),'_CP_EFW_L2_E3D_INERT'];
    eField = local.c_read(dataStr,tint);
    
else
    eField = zeros(1,4);
    disp('Not a spacecraft!')
    return;
end

legLD = [0.02,0.06];

irf_plot(h,eField);
hLeg = irf_legend(h,{'E_{x}','E_{y}','E_{z}'},legLD);
%set(hLeg,'FontSize',20)

ylabel('$E$ [mVm$^{-1}$]','FontSize',16,'interpreter','latex')

irf_zoom(h,'x',tint) 

end