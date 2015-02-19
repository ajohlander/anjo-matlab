function [bField] = plot_3d_b_field(h,tint,scInd,plotMode)
%PLOT_3D_B_FIELD plot 3D FGM data in GSE.
%   PLOT_3D_E_FIELD(h,tint,scInd)

hideXLabel = isequal(get(h,'XTickLabel'),[]);

if(nargin < 4)
    plotMode = 'default';
end

if(scInd == 1 || scInd == 2 || scInd == 3 || scInd == 4)
    dataStr = ['B_vec_xyz_gse__C',num2str(scInd),'_CP_FGM_FULL'];
    bField = local.c_read(dataStr,tint);
    
else
    bField = zeros(1,4);
    disp('Not a spacecraft!')
    return;
end


switch plotMode
    case 'default'
        normB = sqrt(sum(bField(:,2:4).^2,2));
        bField = [bField,normB];
        legStr = {'B_{x}','B_{y}','B_{z}','|B|'};
    case '3d'
        legStr = {'B_{x}','B_{y}','B_{z}'};
        
    case 'abs'
        normB = sqrt(sum(bField(:,2:4).^2,2));
        bField = [bField(:,1),normB];
        scColor = anjo.get_cluster_colors();
        
        set(h,'ColorOrder',[scColor{scInd}])
        %No legend
end


hL = irf_plot(h,bField);


if(strcmp(plotMode,'abs'))
    
else
    legLD = [0.02,0.06];
    hLeg = irf_legend(h,legStr,legLD);
    set(hLeg,'FontSize',20)
    %ylabel(h,'B [nT]','FontSize',20);
end
ylabel(h,'$B$ [nT]','FontSize',16,'interpreter','latex');



irf_zoom(h,'x',tint)

end