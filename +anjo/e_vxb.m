function [eF] = e_vxb(v,B,alpha)
%ANJO.E_VXB Calculates E = -vxB. 
%   E = ANJO.E_VXB(v,B) returns electric field given magnetic field bF [nT]
%   and plasma bulk velocity v [km/s]. Electric field is calculated by:
%   E = -v x B and is returned in [mV/m].
%   
%   E = ANJO.E_VXB(v,B,alpha) introduces a scalar constant alpha so
%   that: E = alpha*(-v x B).
%
%   See also: ANJO.E_JXB, ANJO.TRANSFORM_E_FIELD



if(nargin == 2)
    alpha = 1;
end

vel = irf_resamp(v,B); % resample velocity 

eF = irf_cross(vel,B); % Calculates E = vxB 

eF(:,2:4) = -alpha*eF(:,2:4)*1e3*1e3*1e-9; % Factor -alpha*1e-3 [mV/m]



end

