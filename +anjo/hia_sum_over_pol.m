function [F_2d] = hia_sum_over_pol(F_3d)
%ANJO.HIA_SUM_OVER_POL Sums a 4D ion HIA matrix over the polar angle.
%
%   ionMat = ANJO.HIA_SUM_OVER_POL(ion4d) Given F_3d of size 8x16Nx31,
%   sums over polar angle with factor cos(th). Returns 2d matrix ionMat
%   with size Nx16x31.
%   
%   Also works with reduced energy resolution.
%
%   See also:   ANJO.GET_HIA_DATA
%

tn = size(F_3d,2); % Number of time steps
en = size(F_3d,3); % Number of energy bins

F_2d = zeros(tn,en);
th = anjo.get_hia_values('theta')'; % Equatorial angle

for i = 1:8
    for j = 1:tn
        for k = 1:en
            fval = F_3d(i,j,k)*cosd(th(i));
            F_2d(j,k) = F_2d(j,k)+fval;
        end
    end
end