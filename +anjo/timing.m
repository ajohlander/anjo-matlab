function [V,n,m,rmsV,dTh,eTh,dm2] = timing(T,dTp,dT,R1,R2,R3,R4)
%ANJO.TIMING Calculate velocity with errors with timing method.
%   
% [V,n,m,rmsV,dTh,eTh,dm2] = ANJO.TIMING(T,dTp,dT,R1,R2,R3,R4) Performs timing
%   analysis with:
%   Output: 
%       V       - discontinuity speed
%       n       - normal vector
%       m       - slowness vector (n/V)
%       rmsV    - root-mean-square of V
%       dTh     - errors in propagation angle (semi-major/minor axis of
%               error ellipse)
%       eTh     - corresponding vectors for min and max dTh
%       dm2     - "squared" error for m, scalar or tensor, dm2 = <dm*dm'> 
%               -> dm = diag(sqrt(dm2))
%   Input:
%       T       - epochTT object of crossing time
%       dTp     - time difference of discontinuity between spacecraft with
%               arbitrary time offset 
%       dT      - error in time differences can be a scalar value or a
%               matrix of "squared" values <dt_a dt_b> 
%       R1-R4   -  TSeries ocjects of spacecraft position.
%
% For rmsV, dTh, and eTh, a scalar time error is assumed even if inputted
% tensor. The operation for the scalar is: 
% >> dT = trace(sqrt(dT_tensor))/4; % should be a real number
%
% This function follows the procedure and notation of section 3 & 4 in: 
% Vogt, J., Haaland, S., and Paschmann, G.: 
% Accuracy of multi-point boundary crossing time analysis, 
% Ann. Geophys., 29, 2239-2252, 
% https://doi.org/10.5194/angeo-29-2239-2011, 2011.
%
% Assumes spacecraft formation does not change during crossing time, which
% means that the crossing time should be short, which it always is for MMS,
% and it also means that the speed is calculated in the spacecraft frame
% and not the Earth frame.
%
% The function also assumes that all errors in the spacecraft position are
% small, which should hold for all cases of MMS and Cluster.
% 
% To get time differences and corresponding errors:
% See also: ANJO.TIME_LAG
% 


% Rs are timeseries objects
% T is an epochTT object
% Time differences are doubles with unit seconds


% first check if time error is a scalar or tensor
if size(dT,2) == 4 % is a tensor
    dT_tensor = dT; % tensor value
    dT = trace(sqrt(dT_tensor))/4; % scalar value
elseif size(dT,1) == 1 % is a scalar
    dT_tensor = dT; % "tensor" value
else 
    error('unkown format of dTp')
end


% tetrahedron center 
rstar = 1/4*(R1.resample(T).data+R2.resample(T).data+...
    R3.resample(T).data+R4.resample(T).data)';

% position vectors with origin in tetrahedron center 
c_eval('rstar? = R?.resample(T).data''-rstar;')

% get position tensor Rstar (1)
Rstar = rstar1*rstar1'+rstar2*rstar2'+rstar3*rstar3'+rstar4*rstar4';

% generalized reciprocal vectors q (3), (q=k)
c_eval('q? = inv(Rstar)*rstar?;') 

% reciprocal tensor
K = q1*q1'+q2*q2'+q3*q3'+q4*q4';

% get slowness vector (17), which should hold for arbitrary time offsets
m = q1*dTp(1)+q2*dTp(2)+q3*dTp(3)+q4*dTp(4);

% normal vector from (9)
n = m/norm(m);

% discontinuity velocity from (9)
V = 1/norm(m);

% Get eigenvetors to R
% [eigV,eigD] = eig(Rstar);

% just get some normal vector perp to n
e1 = cross([0;1,;0],n)/norm(cross([0;1;0],n));
% and another
e2 = cross(n,e1);

% get errors in the timing
% Get absolute rms error in velocity (33) (deltaV/V = sqrt(<dV^2>)/V)
rmsV = V^2*dT*sqrt(n'*K*n);

% get error in angle (32)
% not an elegant solution, should be able to predict max and min errors and
% corresponding directions
% get many linear combinations of e1 and e2 (all are perp to n and norm=1)
eArr = e1*cos(linspace(0,2*pi,1e4))+e2*sin(linspace(0,2*pi,1e4));
% loop through all linear combinations and find max and min errors
dThArr = zeros(1,length(eArr));
for ii = 1:length(eArr)
    dThArr(ii) = V*dT*sqrt(eArr(:,ii)'*K*eArr(:,ii));
end
dTh = [min(dThArr),max(dThArr)];
eTh = [eArr(:,dThArr==min(dThArr)),eArr(:,dThArr==max(dThArr))];

% Get error in m
if size(dT_tensor,2) == 4 % tensor
    % from eq (21) and assumes dk (= dq) = 0
    dm2 = zeros(3);
    c_eval('dm2 = dm2+dT_tensor(?,!)*q?*q!'';',1:4,1:4)
else
    % from eq (27) and assumes dr = 0
    dm2 = dT^2*K;
end

end

