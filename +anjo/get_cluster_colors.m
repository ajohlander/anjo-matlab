function [c] = get_cluster_colors(scInd)
%ANJO.GET_CLUSTER_COLORS get line colors for the Cluster satellites
%   c = ANJO.GET_CLUSTER_COLORS() returns colors c = 1x4 cell.
%   c = ANJO.GET_CLUSTER_COLORS(scInd) returns color for spacecraft scInd.
%   
%   Mostly to get the same colors in all figures.

clCol = {[0,0,0],[1,0,0],[0,0.8,0],[0,0,1]};
if(nargin == 0)
    c = clCol;
else
    c = clCol{scInd};
end

end

