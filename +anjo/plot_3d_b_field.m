function [out] = plot_3d_b_field(x1,x2,scInd,plotMode)
%ANJO.PLOT_3D_B_FIELD plot 3D FGM data in GSE.
%   ANJO.PLOT_3D_B_FIELD(AX,tint,scInd) - plots components and amplitude of
%   magnetic field for time interval tint for spacecraft scInd.
%   ANJO.PLOT_3D_B_FIELD(AX,tint,scInd,plotMode)
%   mode:
%       'default'   - plots components and amplitude.
%       '3d'        - plots only components.
%       'abs'       - plots only amplitude.
%
%   ANJO.PLOT_3D_B_FIELD(AX,bField) plots the input B-field with the
%   correct plot mode.
%   ANJO.PLOT_3D_B_FIELD(bField) Initiates a new figure and plots the
%   input B-field.
%   bField = ANJO.PLOT_3D_B_FIELD(...) also returns magnetic field.
%
%   See also: ANJO.GET_3D_B_FIELD, ANJO.GET_3D_E_FIELD,
%   ANJO.PLOT_3D_E_FIELD




if(nargin < 4)
    plotMode = 'default';
end

if(nargin <= 2) % B-field input!
    if(nargin == 1) 
        AX = anjo.afigure(1);
        bField = x1;
        
    elseif(nargin == 2)
        AX = x1;
        bField = x2;
    end
    tint = [min(bField(:,1)),max(bField(:,1))];
    bSize = size(bField);
    switch bSize(2) % Set plotMode after size of input B-field.
        case 5
            plotMode = 'default';
        case 4
            plotMode = '3d';
        case 2
            plotMode = 'abs';
    end
    
else % Get data
    AX = x1;
    tint = x2;
    bField = anjo.get_3d_b_field(tint,scInd,plotMode);
end


switch plotMode
    case 'default'
        legStr = {'B_{x}','B_{y}','B_{z}','|B|'};
    case '3d'
        legStr = {'B_{x}','B_{y}','B_{z}'};
    case 'abs'
        scColor = anjo.get_cluster_colors();
        set(AX,'ColorOrder',[scColor{scInd}])
        %No legend
end

hideXLabel = isequal(get(AX,'XTickLabel'),[]);
irf_plot(AX,bField);


if(strcmp(plotMode,'abs'))
    % No legend
else
    legLD = [0.02,0.06]; % Left down
    irf_legend(AX,legStr,legLD);
end


anjo.label(AX,'$B$ [nT]')

irf_zoom(AX,'x',tint)


if(hideXLabel)
    set(AX,'XTickLabel',[])
end

if(nargout == 1)
    out = bField;
end

end