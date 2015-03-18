function [eF] = e_vxb(bF,v,alpha)
%ANJO.E_VXB Calculates E = jxB/ne. 
%   eF = ANJO.E_VXB(bF,v) returns electric field given magnetic field bF
%   and plasma bulk velocity v and number density n. Electric field is
%   calculated by: E = -v x B.
%   eF = ANJO.E_VXB(bF,v,alpha) introcuces a scalar constant alpha so
%   that: E = alpha*(-v x B).
%
%   See also: ANJO.E_JXB, ANJO.TRANSFORM_E_FIELD



if(nargin == 2)
    alpha = 1;
end

eF = bF; % same size and times

for i = 1:size(bF,1)
    B = bF(i,2:4)/1e9; % B-vector in T
        % interpolates velocity for the time point [m/s]
    vel = interp1(v(:,1),v(:,2:4),bF(i,1))*1e3;
    % Calculates electric field E=-vxB
    eF(i,2:4) = -alpha*cross(vel,B)*1e3;
end

end

