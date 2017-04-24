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
% fast speed        - Vf        - B,V,n,Ti,Te
%
% Frequencies [s^-1] (not radians)
% ion gyrofreq      - Fci       - B
%
% Lengths [km]
% ion inert.len     - di        - n
% ion gyroradius    - rci       - B,V     (not thermal motion)
%
% Unitless
% Alfven Mach no.   - Ma        - B,V,n
% fast Mach no.     - Mf        - B,V,n,Ti,Te
% ion beta          - bi        - n,Ti
% electron beta     - be        - n,Te
%
% ----------------------
% Example 1:
% sp = [];
% sp.B = [10,0,0];
% sp.n = 1;
% sp.Te = 100; sp.Ti=1000;
% dsp = anjo.plasma_params(sp)
%
% dsp = 
% 
%      Va: 218.1204
%      cs: 544.9255
%     Fci: 0.1525
%      di: 227.7108
%      bi: 4.0267
%      be: 0.4027
% ----------------------
% Example 2:
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


% To convert the fast Mach number from upstream value to NIF:
%   vfnif = cms^2
%   Mfnif = 


 %% Handle input
fn = fieldnames(spec);

% find Bs
%idBc = ;
idB = ~cellfun(@isempty,strfind(fn,'B'));
% regions
rgsB = fn(idB); % don't trust the warning
nR = numel(rgsB);
rgs = cell(1,nR);
for k = 1:nR
    rgs{k} = rgsB{k}(end);
    if strcmp(rgs{k},'B')
        rgs{k} = '';
    end
end


if find(ismember(fn,['V',rgs{1}])); hasV = 1; else hasV = 0; end
if find(ismember(fn,['n',rgs{1}])); hasN = 1; else hasN = 0; end
if find(ismember(fn,['Ti',rgs{1}])); hasTi = 1; else hasTi = 0; end
if find(ismember(fn,['Te',rgs{1}])); hasTe = 1; else hasTe = 0; end


%% Calculate parameters
dspec = [];


%% Speeds
% Alfven
if hasN
    for k = 1:nR
        dspec.(['Va',rgs{k}]) = v_alfv(spec.(['B',rgs{k}]),spec.(['n',rgs{k}]));
    end
end
% Sound speed
if hasTi && hasTe
    for k = 1:nR
        dspec.(['cs',rgs{k}]) = v_sound(spec.(['Ti',rgs{k}]),spec.(['Te',rgs{k}]));
    end
end
% Fast
if hasN && hasTi && hasV
    for k = 1:nR
        dspec.(['Vf',rgs{k}]) = v_fast(spec.(['B',rgs{k}]),spec.(['V',rgs{k}]),spec.(['n',rgs{k}]),spec.(['Ti',rgs{k}]),spec.(['Te',rgs{k}]));
    end
end


%% Frequencies
% Ion gyrofrequency
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
% Ion gyroradius
if hasV
    for k = 1:nR
        dspec.(['rci',rgs{k}]) = ion_gyro_rad(spec.(['B',rgs{k}]),spec.(['V',rgs{k}]));
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
if hasV && hasN && hasTi && hasTe
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

Va = irf_abs(B,1)/sqrt(u.mu0*n*u.mp)*1e-15; % km/s
end

function cs = v_sound(Ti,Te) %
u = irf_units;

ye = 1; % Values from Chen book
yi = 3;
cs = sqrt((ye*Te*u.e+yi*Ti*u.e)/u.mp)*1e-3;
end

function Vf =  v_fast(B,V,n,Ti,Te)
th = acosd(dot(B,V,2)./(irf_abs(B,1)*irf_abs(V,1))); % put to 90 to get like Chen

Va = v_alfv(B,n);
cs = v_sound(Ti,Te);
cms0 = sqrt(Va.^2+cs.^2);

Vf = sqrt(cms0.^2/2+sqrt(cms0.^4/4-Va.^2.*cs.^2*cosd(th).^2));
end

function Fci = ion_gyro_freq(B)
u = irf_units;

Fci = u.e*irf_abs(B,1)*1e-9/(u.mp)/(2*pi);
end

function di =  ion_in_len(n) 
u = irf_units;

di = u.c/sqrt(n*1e6*u.e^2/(u.eps0*u.mp))*1e-3;
end

function rci =  ion_gyro_rad(B,V) 
u = irf_units;

rci = u.mp*irf_abs(V,1)*1e3./(u.e*irf_abs(B,1)*1e-9)*1e-3;
end

function bi =  beta_i(B,n,Ti) 
u = irf_units;

bi = n*1e6*Ti*u.e/((norm(B)*1e-9)^2/(2*u.mu0));
end

function be =  beta_e(B,n,Te) 
u = irf_units;

be = n*1e6*Te*u.e/((norm(B)*1e-9)^2/(2*u.mu0));
end

