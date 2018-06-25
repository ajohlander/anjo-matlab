function [n,dTh,V,dV] = cont_timing(tint,S1,S2,S3,S4,R1,R2,R3,R4,dTstep,dTint)
%CONT_TIMING Summary of this function goes here
%   Detailed explanation goes here


% 
if nargin == 10
    dTint = dTstep;
end


% time diffs to centers from start of time interval
dtc = dTint/2:dTstep:(tint.stop.epochUnix-tint.start.epochUnix)-dTint/2;

% time centers in 
tc = tint.start+dtc;

% number of times
nT = length(tc);

disp('Continuous Timing analysis:')
disp(['Start: ',tint.start.toUtc])
disp(['Stop: ',tint.stop.toUtc])
disp(['Length of time interval: ',num2str(tint.stop-tint.start),' s'])
disp(['Number of sub-intervals: ',num2str(nT)])
disp('---------------------------')
V = zeros(nT,1);
dV = zeros(nT,1);
n = zeros(nT,3);
dTh = zeros(nT,1);

for it = 1:nT
    tStart = (tc(it)+-dTint/2);
    tStop = (tc(it)+dTint/2);
    disp([num2str(it),'/',num2str(nT)])
    disp('Sub-interval:')
    disp(['Start: ',tStart.toUtc])
    disp(['Stop: ',tStop.toUtc])
    disp('---------------------------')
    [tau,dtau2] = anjo.time_lag(tc(it)+[-dTint,dTint]/2,S1,S2,S3,S4);
    dT = trace(sqrt(dtau2))/4;
    [V(it),n(it,:),~,dV(it),dThTemp,~,~] = anjo.timing(tc(it),tau,dT,R1,R2,R3,R4);
    dTh(it) = mean(dThTemp);
end

V = irf.ts_scalar(tc,V);
dV = irf.ts_scalar(tc,dV);
n = irf.ts_vec_xyz(tc,n);
dTh = irf.ts_scalar(tc,dTh);


end

