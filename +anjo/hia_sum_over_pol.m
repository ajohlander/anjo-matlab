function [F_2d] = hia_sum_over_pol(F_3d)
%ANJO.HIA_SUM_OVER_POL Sums a 4D ion HIA matrix over the polar angle.
%
%   ionMat = ANJO.HIA_SUM_OVER_POL(ion4d) Given ion4d of size Nx8x16x31,
%   sums over polar angle with factor sin(th). Returns 3d matrix ionMat
%   with size Nx16x31.
%
%   See also:   ANJO.GET_HIA_DATA
%
% 
% if(length(size(ion4d)) == 4)
%     tNum = size(ion4d,1);
%     phiN = 16;
%     d4 = 1;
% else
%     tNum = 1;
%     phiN = size(ion4d,2);
%     d4 = 0;
% end
% ionMat = zeros(tNum,phiN,31);
% th = anjo.get_hia_values('theta')';
% 
% for i = 1:tNum
%     for j = 1:8
%         for k = 1:phiN
%             for l = 1:31
%                 if d4
%                     ionMat(i,k,l) = ionMat(i,k,l)+ion4d(i,j,k,l)*sind(th(j));
%                 else
%                     ionMat(i,k,l) = ionMat(i,k,l)+ion4d(j,k,l)*sind(th(j));
%                 end
%             end
%         end
%     end
% end
% end


% New reasonable version:
% Input is F_3d, size: 8x16Nx31


phiN = size(F_3d,2);

F_2d = zeros(phiN,31);
th = anjo.get_hia_values('theta')'; %Polar angle

for i = 1:8
    for j = 1:phiN
        for k = 1:31
            fval = F_3d(i,j,k)*sind(th(i));
            F_2d(j,k) = F_2d(j,k)+fval;
        end
    end
end