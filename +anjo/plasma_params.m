function dspec = plasma_params(spec)
% ANJO.PLASMA_PARAMS Calculate shock related plasma parameters.
% 
% dspec = ANJO.PLASMA_PARAMS(spec) Returns struct dspec with derived plasma
% parameters from input struct spec with measured plasma parameters.
% 
% Input struct has parameters input with fixed names. After the parameter
% name, a name of the region can be given, e.g. "u" and "d". All parameters
% except B are optional.
%
% INPUT PARAMETERS:
% Magnetic field vector [nT]        -   B
% Plasma velocity [km/s]            -   V
% Plasma number density [cm^-3]     -   n
% ion/electron temperature [eV]     -   Ti/Te
%
% OUTPUT PARAMETERS - symbol    - required input parameters
% Speeds [km/s]
% Alfven speed      - Va        - B,n
% fast speed        - Vf        - B,n,Ti,Te
%
% Frequencies [s^-1] (not radians)
% ion gyrofreq      - Fci       - B,V     (not thermal motion)
%
% Lengths [km]
% ion inert.len     - di        - n
% ion gyroradius    - rci       - B,v     (not thermal motion)
%
% Unitless
% Alfven Mach no.   - Ma        - B,V,n
% fast Mach no.     - Mf        - B,V,n,Ti,Te
% ion beta          - bi        - n,Ti
% electron beta     - be        - n,Te
% 
% Example:
% sp = [];
% sp.Bu = 5; sp.Bd = 20;
% sp.nu = 3; sp.nd = 12;
% dsp = anjo.plasma_params(sp)
% 
% dsp = 
% 
%      Vau: 62.9659
%      Vad: 125.9318
%     Fcid: 0.3049
%     Fcid: 0.3049
%      diu: 131.4689
%      did: 65.7344
% 
%
% See also: IRF_PLASMA_CALC ANJO.SHOCK_NORMAL
% 


 %% Handle input
fn = fieldnames(spec);

% find Bs
idB_cell = strfind(fn,'B');
% regions
rgsB = fn(find([idB_cell{:}])); % don't trust the warning
nR = numel(rgsB);
rgs = cell(1,nR);
for k = 1:nR
    rgs{k} = rgsB{k}(end);
end

if find(ismember(fn,['V',rgs{1}]))
    hasV = 1;
else
    hasV = 0;
end
if find(ismember(fn,['n',rgs{1}]))
    hasN = 1;
else
    hasN = 0;
end
if find(ismember(fn,['Ti',rgs{1}]))
    hasTi = 1;
else
    hasTi = 0;
end
if find(ismember(fn,['Te',rgs{1}]))
    hasTe = 1;
else
    hasTe = 0;
end


%% Calculate parameters
dspec = [];


%% Speeds
% Alfven
if hasN
    for k = 1:nR
        dspec.(['Va',rgs{k}]) = v_alfv(spec.(['B',rgs{k}]),spec.(['n',rgs{k}]));
    end
end
% Fast
if hasN && hasTi
    for k = 1:nR
        dspec.(['Vf',rgs{k}]) = v_fast(spec.(['B',rgs{k}]),spec.(['n',rgs{k}]),spec.(['Ti',rgs{k}]),spec.(['Te',rgs{k}]));
    end
end


%% Frequencies
for k = 1:nR
    dspec.(['Fci',rgs{k}]) = ion_gyro_freq(spec.(['B',rgs{k}]));
end

%% Lenghts
% Ion inertial length
if hasN 
    for k = 1:nR
        dspec.(['di',rgs{k}]) = ion_in_len(spec.(['n',rgs{k}]));
    end 
end

if hasV
    for k = 1:nR
        dspec.(['rg',rgs{k}]) = ion_gyro_rad(spec.(['B',rgs{k}]),spec.(['V',rgs{k}]));
    end 
end


%% Dimensionless
% Alfven Mach
if hasV && hasN 
    for k = 1:nR
        dspec.(['Ma',rgs{k}]) = norm(spec.(['V',rgs{k}]))/dspec.(['Va',rgs{k}]);
    end 
end
% fast Mach
if hasV && hasN 
    for k = 1:nR
        dspec.(['Mf',rgs{k}]) = norm(spec.(['V',rgs{k}]))/dspec.(['Vf',rgs{k}]);
    end 
end
% ion beta
if hasN && hasTi
    for k = 1:nR
        dspec.(['bi',rgs{k}]) = beta_i(spec.(['B',rgs{k}]),spec.(['n',rgs{k}]),spec.(['Ti',rgs{k}]));
    end 
end
% electron beta
if hasN && hasTe
    for k = 1:nR
        dspec.(['be',rgs{k}]) = beta_e(spec.(['B',rgs{k}]),spec.(['n',rgs{k}]),spec.(['Te',rgs{k}]));
    end 
end


end

%% Help functions

function Va =  v_alfv(B,n) 
u = irf_units;

Va = norm(B)/sqrt(u.mu0*n*u.mp)*1e-15; % km/s
end

function Vf =  v_fast(B,n,Ti,Te) % from Chen
u = irf_units;
y = 5/3;

Va = v_alfv(B,n)*1e3;
cs = sqrt((Te+y*Ti)*u.e/u.mp);

Vf = u.c*sqrt((Va^2+cs^2)/(u.c^2+Va^2))*1e-3;
%Vf = sqrt( Va^2+cs^2+sqrt(((Va^2+cs^2)^2+4*Va^2*cs^2)) )*1e-3;
end

function Fci = ion_gyro_freq(B)
u = irf_units;

Fci = u.e*norm(B)*1e-9/(u.mp)/(2*pi);
end

function di =  ion_in_len(n) 
u = irf_units;

di = u.c/sqrt(n*1e6*u.e^2/(u.eps0*u.mp))*1e-3;
end

function rg =  ion_gyro_rad(B,V) 
u = irf_units;

rg = u.mp*norm(V)*1e3/(u.e*norm(B)*1e-9)*1e-3;
end

function bi =  beta_i(B,n,Ti) 
u = irf_units;

bi = n*1e6*Ti*u.e/((norm(B)*1e-9)^2/(2*u.mu0));
end

function be =  beta_e(B,n,Te) 
u = irf_units;

be = n*1e6*Te*u.e/((norm(B)*1e-9)^2/(2*u.mu0));
end

