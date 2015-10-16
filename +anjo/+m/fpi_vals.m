function [x1,x2,x3,x4] = fpi_vals()
%ANJO.M.FPI_VALS Returns guessed values for FPI
%   
%   Detailed explanation goes here
%   [th,phi,ie,ee] = ANJO.M.VALS.FPI_VALS
%


% returns an additional row vector, centers, indicating the location 
% of each bin center on the x-axis.
[~,th] = hist([-90,90],16);
[~,phi] = hist([-180,180],32);

% For ions energy is from 10 eV to 30 keV. Same for electrons?
% Lin -> Log. Not sure its good.
[~,xi] = hist([log10(10),log10(30e3)],32);
[~,xe] = hist([log10(10),log10(30e3)],32);

ie = 10.^xi;
ee = 10.^xe;

% Out
x1 = th;
x2 = phi;
x3 = ie;
x4 = ee;


end

