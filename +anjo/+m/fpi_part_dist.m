function [Fpart] = fpi_part_dist(F,ide,idp,idth)
%ANJO.M.FPI_PART_DIST Extract parts of distibution function.
%   
%   Fpart = ANJO.M.FPI_PART_DIST(F,ide,idp,idth) Returns partial
%   distibution function Fpart given indicies ide, idp and idth for energy,
%   phi and th respectively. All other values are set to zero. Set any
%   index vector to 'all' to keep all values.
%
%   Example: Fpart = anjo.m.fpi_part_dist(F,'all',10:23,'all'); 
%   Returns distribution of particles moving toward the Sun (-90<phi<90).
%
%   See also: ANJO.M.FPI_VALS
%


if strcmpi(ide,'all')
    ide = 1:32;
end
if strcmpi(idp,'all')
    idp = 1:32;
end
if strcmpi(idth,'all')
    idth = 1:16;
end

Fpart = F;

fp = zeros(size(F.data)); %[t,E,phi,th]

fp(:,ide,idp,idth) = F.data(:,ide,idp,idth);

Fpart.data = fp;

end

