function [ionMat] = hia_sum_over_pol(ion4d)
%ANJO.HIA_SUM_OVER_POL Sums a 4D ion HIA matrix over the polar angle.
%
%   ionMat = ANJO.HIA_SUM_OVER_POL(ion4d) Given ion4d of size Nx8x16x31,
%   sums over polar angle with factor sin(th). Returns 3d matrix ionMat
%   with size Nx16x31.
%
%   See also:   ANJO.GET_HIA_DATA
%

tNum = size(ion4d,1);
ionMat = zeros(tNum,16,31);
th = anjo.get_hia_values('theta')';

for i = 1:tNum
    for j = 1:8
        for k = 1:16
            for l = 1:31
                ionMat(i,k,l) = ionMat(i,k,l)+ion4d(i,j,k,l)*sind(th(j));
            end
        end
    end
end
end

