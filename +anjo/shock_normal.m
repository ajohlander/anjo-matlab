function [varargout] = shock_normal(spec,leq90)
%SHOCK_NORMAL Calculates shock normals with different methods.
%
%   Normal vectors are calculated by methods described in ISSI Scientific
%   Report SR-001 Ch 10. (Schwartz 1998), and references therein.
%   
%   nd = SHOCK_NORMAL(spec) returns structure nd which contains data
%   on shock normal vectors given input with plasma parameters spec.
%
%   Input spec contains:
%
%       Bu  -   Upstream magnetic field
%       Bd  -   Downstream magnetic field
%       Vu  -   Upstream plasma bulk velocity
%       Vd  -   Upstream plasma bulk velocity
%       Optional:
%       R   -   Spacecraft position as given by R =
%       mms.get_data('R_gse',tint).
%       d2u -   Down-to-up, is 1 or -1.
%       dTf -   Delta t_foot.
%       Fcp -   Reflected ion gyrofrequency in Hz.
%       
%
%   Output nd contains:
%
%       n   -   Structure containing normal vectors:
%           From data:
%               mc  -   Magnetic coplanarity
%               vc  -   Velocity coplanarity
%               mx1 -   Mixed method 1
%               mx2 -   Mixed method 2
%               mx3 -   Mixed method 3
%           Models (only if R is included in spec):
%               farris  -   Farris, M. H., et al., 1991
%               slho    -   Slavin, J. A. and Holzer, R. E., 1981 (corrected)
%               per     -   Peredo et al., z = 0
%               fa4o    -   Fairfield, D. H., 1971
%               fan4o   -   Fairfield, D. H., 1971
%               foun    -   Formisano, V., 1979
%
%       thBn -  Angle between normal vector and spec.Bu, same fields as n.
%
%       thVn -  Angle between normal vector and spec.Vu, same fields as n.
%
%       Vsh  -  Structure containing shock velocities:
%            Methods:
%               gt  -   Gosling-Thomsen method using shock foot thickness.
%               mf  -   Mass flux conservation.
%               sb  -   Smith-Burton method (Gives two roots for some reason)
%
%       info -  Some more info:
%           msh     -   Magnetic shear angle
%           vsh     -   Velocity shear angle
%           cmat    -   Constraints matrix with normalized errors.
%           Calclated from (10.9-10.13) in (Schwartz 1998).
%
%   TODO:   Create GUI and do Monte Carlo to establish error bars.
%           Implement good shock velocity estimate.


% normal vector, according to different models
nd = [];
n = [];

% leq90 = 1 if angles should be less or equal to 90 deg. 0 is good if doing
% statistics
if nargin == 1
    leq90 = 1;
end


Bu = spec.Bu;
Bd = spec.Bd;
Vu = spec.Vu;
Vd = spec.Vd;

delB = Bd-Bu;
delV = Vd-Vu;
spec.delB = delB;
spec.delV = delV;

% magenetic coplanarity
n.mc = cross(cross(Bd,Bu),delB)/norm(cross(cross(Bd,Bu),delB));

% velocity coplanarity
n.vc = delV/norm(delV);

% Mixed methods
n.mx1 = cross(cross(Bu,delV),delB)/norm(cross(cross(Bu,delV),delB));
n.mx2 = cross(cross(Bd,delV),delB)/norm(cross(cross(Bd,delV),delB));
n.mx3 = cross(cross(delB,delV),delB)/norm(cross(cross(delB,delV),delB));


% calculate model normals if R is inputted
if isfield(spec,'R')
    % Farris et al.
    n.farris = farris_model(spec);
    % Slavin and Holzer mean
    n.slho = slavin_holzer_model(spec);
    % Peredo et al., z = 0
    n.per = peredo_model(spec);
    % Fairfield Meridian 4o
    n.fa4o = fairfield_meridian_4o_model(spec);
    % Fairfield Meridian No 4o
    n.fan4o = fairfield_meridian_no_4o_model(spec);
    % Formisano Unnorm. z = 0
    n.foun = formisano_unnorm_model(spec);
end

% shock angle
thBn = shock_angle(spec,n,'B',leq90);
thVn = shock_angle(spec,n,'V',leq90);


% Shock velocity from foot time
% Fcp in Hz as given by irf_plasma_calc.
% Shock foot timing (Gosling et al., 1982)
Vsh.gt = shock_speed(spec,n,thBn,'gt');
% Shock velocity from mass flux conservation
Vsh.mf = shock_speed(spec,n,thBn,'mf');
% Shock velocity from (Smith & Burton, 1988)
Vsh.sb = shock_speed(spec,n,thBn,'sb');


% info
info = [];
% magnetic shear angle
info.msh = shear_angle(Bu,Bd);
% velocity shear angle
info.vsh = shear_angle(Vu,Vd);

info.cmat = constraint_values(spec,n);

% gather data
nd.info = info;
nd.n = n;
nd.thBn = thBn;
nd.thVn = thVn;
nd.Vsh = Vsh;

if nargout >= 1
    varargout{1} = nd;
else
    fnames = fieldnames(n);
    for i = 1:length(fnames)
        fprintf(['n_',fnames{i},'\t = \t',num2str(n.(fnames{i})),'\n'])
    end
end
        
end

function th = shear_angle(Au,Ad)

th = acosd(dot(Au,Ad)/(norm(Au)*norm(Ad)));

end

function th = shock_angle(spec,n,field,leq90)
% field is 'B' or 'V'

switch lower(field)
    case 'b'
        a = spec.Bu;
    case 'v'
        a = spec.Vu;
end

fnames = fieldnames(n);
num = length(fnames);

for i = 1:num
    th.(fnames{i}) = thFn(n.(fnames{i}),a,leq90);
end

end
function th = thFn(nvec,a,leq90)
th = acosd(dot(a,nvec)/(norm(a)));
if th>90 && leq90
    th = 180-th;
end
end

function cmat = constraint_values(spec,n)

fnames = fieldnames(n);
num = length(fnames);
cmat = zeros(5,num);

fun1 = @(nvec)dot(spec.delB,nvec)/norm(spec.delB);
fun2 = @(nvec)dot(cross(spec.Bd,spec.Bu),nvec)/norm(cross(spec.Bd,spec.Bu));
fun3 = @(nvec)dot(cross(spec.Bu,spec.delV),nvec)/norm(cross(spec.Bu,spec.delV));
fun4 = @(nvec)dot(cross(spec.Bd,spec.delV),nvec)/norm(cross(spec.Bd,spec.delV));
fun5 = @(nvec)dot(cross(spec.delB,spec.delV),nvec)/norm(cross(spec.delB,spec.delV));

c_eval('cmat(?,:) = structfun(fun?,n);',1:5)

% fields that are by definition zero are set to 0?
idz = sub2ind(size(cmat),[1,1,1,1,2,3,3,4,4,5,5],[1,3,4,5,1,2,3,2,4,2,5]);
cmat(idz) = 0;
end

function Vsp = shock_speed(spec,n,thBn,method)

fn = fieldnames(n);
N = length(fn);


switch lower(method)
    case 'gt' % Gosling & Thomsen
        if ~isfield(spec,'Fcp') || ~isfield(spec,'dTf') || ~isfield(spec,'d2u')
            for k = 1:N
                Vsp.(fn{k}) = 0;
            end
            return;
        else
           Vsp = speed_gosling_thomsen(spec,n,thBn,fn);
        end
    case 'mf' % Mass flux
        Vsp = speed_mass_flux(spec,n,fn);
    case 'sb' % Smith & Burton
        Vsp = speed_smith_burton(spec,n,fn);
end


end

function Vsp = speed_gosling_thomsen(spec,n,thBn,fn)
for k = 1:length(fn)
    th = thBn.(fn{k})*pi/180;
    nvec = n.(fn{k});
    
    % Notation as in (Gosling and Thomsen 1985)
    W = spec.Fcp*2*pi;
    t1 = acos((1-2*cos(th).^2)./(2*sin(th).^2))/W;
    
    f = @(th)W*t1*(2*cos(th).^2-1)+2*sin(th).^2.*sind(W*t1);
    x0 = f(th)/(W*spec.dTf);
    
    Vsp.(fn{k}) = dot(spec.Vu,nvec)*(x0/(1+spec.d2u*x0));
end
end

function Vsp = speed_mass_flux(spec,n,fn)
% Assume all protons, not very good but no composition available
u = irf_units;

rho_u = spec.nu*u.mp;
rho_d = spec.nd*u.mp;

for k = 1:1:length(fn)
    Vsp.(fn{k}) = (rho_d*dot(spec.Vd,n.(fn{k}))-rho_u*dot(spec.Vu,n.(fn{k})))/(rho_d-rho_u);
end
end

function Vsp = speed_smith_burton(spec,n,fn)
% Two solutions Vsp = Vun +- |dVxBd|/|dB|. Find a good way to pick the
% correct one.
for k = 1:1:length(fn)
     Vsp.(fn{k}) = dot(spec.Vu,n.(fn{k}))+[1,-1]*norm(cross((spec.Vd-spec.Vu),spec.Bd))/norm(spec.Bd-spec.Bu);
end

end


function n = farris_model(spec)
eps = 0.81;
L = 24.8; % in RE
x0 = 0;
y0 = 0;

alpha = 3.8;

n = shock_model(spec,eps,L,x0,y0,alpha);
end

function n = slavin_holzer_model(spec) %
eps = 1.16;
L = 23.3; % in km
x0 = 3.0;
y0 = 0;
alpha = atand(spec.Vu(2)/spec.Vu(1));

n = shock_model(spec,eps,L,x0,y0,alpha);
end

function n = peredo_model(spec) %
eps = 0.98;
L = 26.1; % in km
x0 = 2.0;
y0 = 0.3;
alpha = 3.8-0.6;

n = shock_model(spec,eps,L,x0,y0,alpha);
end

function n = fairfield_meridian_4o_model(spec) %
eps = 1.02;
L = 22.3; % in km
x0 = 3.4;
y0 = 0.3;
alpha = 4.8;

n = shock_model(spec,eps,L,x0,y0,alpha);
end

function n = fairfield_meridian_no_4o_model(spec) %
eps = 1.05;
L = 20.5; % in km
x0 = 4.6;
y0 = 0.4;
alpha = 5.2;

n = shock_model(spec,eps,L,x0,y0,alpha);
end

function n = formisano_unnorm_model(spec) %
eps = 0.97;
L = 22.8; % in km
x0 = 2.6;
y0 = 1.1;
alpha = 3.6;

n = shock_model(spec,eps,L,x0,y0,alpha);
end


function n = shock_model(spec,eps,L,x0,y0,alpha) % Method from ISSI book
u = irf_units;

% rotation matrix
R = [cosd(alpha),-sind(alpha),0;sind(alpha),cosd(alpha),0;0,0,1];

% offset from GSE
r0 = [x0;y0;0];

% sc position in GSE (or GSM or whatever) in Earth radii
rsc = spec.R.gseR1(1,1:3)'/(u.RE*1e-3);

% Calculate sigma
% sc position in the natural system (cartesian)
rp = @(sig)R*rsc-sig.*r0;
% sc polar angle in the natural system
thp = @(sig)cart2pol([1,0,0]*rp(sig),[0,1,0]*rp(sig)); % returns angle first
% minimize |LH-RH| in eq 10.22
fval = @(sig)abs(sig.*L./sqrt(sum(rp(sig).^2,1))-1-eps*cos(thp(sig)));

% find the best fit for sigma
sig0 = fminsearch(fval,0);


% calculate normal
xp = [1,0,0]*rp(sig0);
yp = [0,1,0]*rp(sig0);
zp = [0,0,1]*rp(sig0);

% gradient to model surface
gradS = [(xp*(1-eps^2)+eps*sig0*L)*cosd(alpha)+yp*sind(alpha);...
    -(xp*(1-eps^2)+eps*sig0*L)*sind(alpha)+yp*cosd(alpha);...
    zp]/(norm(rp(sig0))*2*sig0*L);
% normal vector
n = gradS/norm(gradS);
end



