function [] = c2m_col(AX,type,sc2sc)
%ANJO.M.C2M_COL Changes color of lines in a plot from Cluster to MMS.
%
%   ANJO.M.C2M_COL(AX) Finds all Line objects in an array of Axes and
%   changes the color of them from Cluster to MMS standard.
%
%   ANJO.M.C2M_COL(AX,type,sc2sc) Specify type (e.g: 'Text', 'Patch') and
%   in which direction colors should be changed, 'm2c' to change from MMS
%   to Cluster.
%
%   Colors are defined as:
%    % from irf_pl_tx
%    cluster_colors = {[0 0 0]; [1 0 0];[0 0.5 0];[0 0 1];[0 1 1]};
%    % From https://lasp.colorado.edu/galaxy/display/mms/Plot+Standards
%    mms_colors = {[0 0 0]; [213,94,0]/255;[0,158,115]/255;[86,180,233]/255;[0 1 1]};

% Possible types
pt = {'Line','Text'};

if nargin < 2
    type = 'all';
end
if nargin < 3
    sc2sc = 'c2m';
end

if strcmpi(type,'all')
    for i = 1:length(pt)
        anjo.m.c2m_col(AX,pt{i},sc2sc);
    end
    return;
end

if length(AX) > 1
    for i = 1:length(AX)
        anjo.m.c2m_col(AX(i),type,sc2sc);
    end
    return;
else
    % from irf_pl_tx
    cluster_colors = {[0 0 0]; [1 0 0];[0 0.5 0];[0 0 1];[0 1 1]};
    % From https://lasp.colorado.edu/galaxy/display/mms/Plot+Standards
    mms_colors = anjo.m.color;
    
    switch lower(sc2sc)
        case 'c2m'
            col1 = cluster_colors;
            col2 = mms_colors;
        case 'm2c'
            col1 = mms_colors;
            col2 = cluster_colors;
    end
    
    nc = length(col1);
    
    % Find all of Type type
    h = findall(AX.Children,'Type',type);
    
    nl = length(h);
    count = 0;
    
    for i = 1:nl
        col = h(i).Color;
        for j = 1:nc
            if isequal(col,col1{j})
                h(i).Color = col2{j};
                count = count+1;
            end
        end
    end
    irf.log('w',['Changed colors on ',num2str(count),' ',type,'(s).'])
end

end

