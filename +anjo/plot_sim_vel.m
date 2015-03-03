function [] = plot_sim_vel(h,vFinal,plotMode)
%ANJO.PLOT_SIM_VEL plots final velocity vs initial velocity
%   ANJO.PLOT_SIM_VEL(h,vFinal,plotMode) plots final velocity over initial
%   velocity for axis handle h. Data in matrix vFinal.
%
%   mode:
%       '3d'    - all components
%       'x'     - only x component
%
%   See also:   ANJO.LORENTZ_1D

hideXLabel = isequal(get(h,'XTickLabel'),[]);


if(nargin<3)
    plotMode = '3d';
end

switch plotMode
    case '3d'
        irf_plot(h,vFinal/1e3)
        ylabel(h,'$v_f$ [kms$^{-1}$]','interpreter','latex','FontSize',16)
        irf_legend(h,{'v_x','v_y','v_z'},[0.95,0.05])
    case 'x'
        irf_plot(h,vFinal(:,1:2)/1e3)
        ylabel(h,'$v_x,f$ [kms$^{-1}$]','interpreter','latex','FontSize',16)    
end



if(hideXLabel)
    set(h,'XTickLabel',[])
else
    xlabel(h,'$v_i$ [kms$^{-1}$]','interpreter','latex','FontSize',16)
end


end