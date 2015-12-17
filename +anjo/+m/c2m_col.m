function [] = c2m_col(AX)
%ANJO.M.C2M_COL Changes color of lines in a plot from Cluster to MMS.
%
%   ANJO.M.C2M_COL(AX) Finds all Line objects in an array of Axes and
%   changes the color of them from Cluster to MMS standard.
%
%   Colors are defined as:
%    % from irf_pl_tx
%    cluster_colors = {[0 0 0]; [1 0 0];[0 0.5 0];[0 0 1];[0 1 1]};
%    % From https://lasp.colorado.edu/galaxy/display/mms/Plot+Standards
%    mms_colors = {[0 0 0]; [213,94,0]/255;[0,158,115]/255;[86,180,233]/255;[0 1 1]};


if length(AX) > 1
    for i = 1:length(AX)
        anjo.m.c2m_col(AX(i));
    end
    return;
else
    % from irf_pl_tx
    cluster_colors = {[0 0 0]; [1 0 0];[0 0.5 0];[0 0 1];[0 1 1]};
    % From https://lasp.colorado.edu/galaxy/display/mms/Plot+Standards
    mms_colors = {[0 0 0]; [213,94,0]/255;[0,158,115]/255;[86,180,233]/255;[0 1 1]};
    
    nc = length(cluster_colors);
    
    % Find all lines
    hline = findall(AX.Children,'Type','Line');
    
    nl = length(hline);
    count = 0;
    
    for i = 1:nl
        col = hline(i).Color;
        for j = 1:nc
            if isequal(col,cluster_colors{j})
                hline(i).Color = mms_colors{j};
                count = count+1;
            end
        end
    end
    irf.log('w',['Changed colors on ',num2str(count),' lines.'])
end

end

