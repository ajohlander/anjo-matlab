function [] = plot_sim_vel(AX,vFinal,varargin)
%ANJO.PLOT_SIM_VEL plots final velocity vs initial velocity
%   ANJO.PLOT_SIM_VEL(AX,vFinal,component,plotMode) plots final velocity over initial
%   velocity for axis handle AX. Data in matrix vFinal.
%
%   component:
%       '3d'    - all components, default
%       'x'     - only x component
%   mode:
%       'line'      - default
%       'scatter'
%
%   See also:   ANJO.LORENTZ_1D


% Possible pararmeters, default is the first element.
possComp = {'3d','x'};
possMode = {'line','scatter'};

% Get parameters, deafult if not set.
[component,plotMode] = anjo.incheck(varargin,possComp,possMode);

switch component
    case '3d'
        vf = vFinal/1e3;
        irf_legend(AX,{'v_x','v_y','v_z'},[0.95,0.05])
    case 'x'
        vf = vFinal(:,1:2)/1e3;
end

switch plotMode
    case 'line'
        irf_plot(AX,vf)
    case 'scatter'
        scatter(AX,vf(:,1),vf(:,2),'.')
end

anjo.label(AX,'x','$v_{i}$ [kms$^{-1}$]')
anjo.label(AX,'y','$v_{f}$ [kms$^{-1}$]')

if(isfield(AX.UserData.XLabel,'Visible') && strcmp(AX.UserData.XLabel.Visible,'off'))
    AX.XTickLabel = '';
    AX.XLabel.String = '';
end

AX.Box = 'on';

end