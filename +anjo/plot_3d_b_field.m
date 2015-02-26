function [bField] = plot_3d_b_field(h,x1,scInd,plotMode)
%ANJO.PLOT_3D_B_FIELD plot 3D FGM data in GSE.
%   ANJO.PLOT_3D_B_FIELD(h,tint,scInd) - plots components and amplitude of
%   magnetic field for time interval tint for spacecraft scInd.
%   ANJO.PLOT_3D_B_FIELD(h,tint,scInd,plotMode)
%   mode:
%       'default'   - plots components and amplitude.
%       '3d'        - plots only components.
%       'abs'       - plots only amplitude.
%
%   bField = ANJO.PLOT_3D_B_FIELD(h,tint,scInd) also returns magnetic field.
%
%   See also: ANJO.GET_3D_B_FIELD, ANJO.GET_3D_E_FIELD,
%   ANJO.PLOT_3D_E_FIELD


hideXLabel = isequal(get(h,'XTickLabel'),[]);

if(nargin < 4)
    plotMode = 'default';
end

if(nargin == 2) %B-field input!
    bField = x1;
    tint = [min(bField(:,1)),max(bField(:,1))];
else
    tint = x1;
    bField = anjo.get_3d_b_field(tint,scInd,plotMode);
end


switch plotMode
    case 'default'
        legStr = {'B_{x}','B_{y}','B_{z}','|B|'};
    case '3d'
        legStr = {'B_{x}','B_{y}','B_{z}'};

    case 'abs'
        scColor = anjo.get_cluster_colors();

        set(h,'ColorOrder',[scColor{scInd}])
        %No legend
end

irf_plot(h,bField);


if(strcmp(plotMode,'abs'))
    
else
    legLD = [0.02,0.06];
    irf_legend(h,legStr,legLD);
end


ylabel(h,'$B$ [nT]','FontSize',16,'interpreter','latex');

irf_zoom(h,'x',tint)


if(hideXLabel)
    set(h,'XTickLabel',[])
end

end