function [] = plot_sim_vel(h,vFinal,component,plotMode)
%ANJO.PLOT_SIM_VEL plots final velocity vs initial velocity
%   ANJO.PLOT_SIM_VEL(h,vFinal,component,plotMode) plots final velocity over initial
%   velocity for axis handle h. Data in matrix vFinal.
%
%   component:
%       '3d'    - all components, default
%       'x'     - only x component
%   mode:
%       'line'      - default
%       'scatter'
%
%   See also:   ANJO.LORENTZ_1D
%
%   TODO: flags

hideXLabel = isequal(get(h,'XTickLabel'),[]);

if(nargin < 4)
    component = '3d';
end
if(nargin < 3)
    plotMode = 'line';
end


switch component
    case '3d'
        vf = vFinal/1e3;
        anjo.label(h,'y','$v_{f}$ [kms$^{-1}$]')
        irf_legend(h,{'v_x','v_y','v_z'},[0.95,0.05])
    case 'x'
        vf = vFinal(:,1:2)/1e3;
        anjo.label(h,'y','$v_{x,f}$ [kms$^{-1}$]')
end

switch plotMode
    case 'line'
        irf_plot(h,vf)
    case 'scatter'
        scatter(h,vf(:,1),vf(:,2))
end
        




if(hideXLabel)
    set(h,'XTickLabel',[])
else
    anjo.label(h,'x','$v_i$ [kms$^{-1}$]')
end

h.Box = 'on';

end