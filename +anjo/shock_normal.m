function [varargout] = shock_normal(spec)
%ANJO.SHOCK_NORMAL Calculates shock normals with different methods.
%
%   Normal vectors are calculated by methods described in ISSI Scientific
%   Report SR-001 Ch 10. (Schwartz 1998), and references therein.
%   
%   nd = ANJO.SHOCK_NORMAL(spec) returns structure nd which contains data
%   on shock normal vectors given input with plasma parameters spec.
%
%   Input spec contains:
%
%       Bu  -   Upstream magnetic field
%       Bd  -   Downstream magnetic field
%       Vu  -   Upstream plasma bulk velocity
%       Vd  -   Upstream plasma bulk velocity
%       R   -   Spacecraft position as given by R =
%       mms.get_data('R_gse',tint). (can be omitted)
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
%               farris  -   Farris model
%               slho    -   Slavin-Holzer model (not working now)
%
%       thBn -  Angle between normal vector and spec.Bu, same fields as n.
%
%       thVn -  Angle between normal vector and spec.Vu, same fields as n.
%
%       info -  Some more info:
%           msh     -   Magnetic shear angle
%           vsh     -   Velocity shear angle
%           cmat    -   Constraints matrix with normalized errors.
%           Calclated from (10.9-10.13) in (Schwartz 1998).
%
%   TODO:   Fix and implement more models.
%           Create GUI and do Monte Carlo to establish error bars.


% normal vector, according to different models
nd = [];
n = [];

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
    % Farris model
    n.farris = farris_model(spec);
    % Slavin-Holzer model
    n.slho = slavin_holzer_model(spec);
end

% shock angle
thBn = shock_angle(spec,n,'B');
thVn = shock_angle(spec,n,'V');

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


if nargout >= 1;
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

function th = shock_angle(spec,n,field)
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
    th.(fnames{i}) = thFn(n.(fnames{i}),a);
end

end
function th = thFn(nvec,a)
th = acosd(dot(a,nvec)/(norm(a)));
if th>90
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

function n = farris_model(spec)
u = irf_units;
eps = 0.81;
L = 24.8*u.RE*1e-3; % in km
x0 = 0*u.RE;
y0 = 0*u.RE;

n = shock_model(spec,eps,L,x0,y0);
end


function n = slavin_holzer_model(spec) % Only produces NaNs
u = irf_units;
eps = 1.16;
L = 23.3*u.RE*1e-3; % in km
x0 = 3.0*u.RE;
y0 = 0*u.RE;

n = shock_model(spec,eps,L,x0,y0);
end

function n = shock_model(spec,eps,L,x0,y0) %probably a bit bugged

R0 = [x0;y0;0];
r0 = norm(R0);
alpha = atand(spec.Vu(2)/spec.Vu(1));
% rotation matrix
M = [cosd(alpha),-sind(alpha),0;sind(alpha),cosd(alpha),0;0,0,1];

R_sc = spec.R.gseR1(1,1:3)';
r_sc = norm(R_sc);

R_abd = M*R_sc-R0;

x_abd = R_abd(1);
y_abd = R_abd(2);
z_abd = R_abd(3);

[th_abd,r_abd] = cart2pol(x_abd,norm([y_abd,z_abd]));


% % Fit though sc position
% sig = r_abd/L*(1+eps*cosd(th_abd))
% L = sig*L;


% alt
p = ((r0^2-2*dot(M*R_sc,R0))/L)*(1+eps*cos(th_abd))^2;
q = -r_sc^2/L^2*(1+eps*cos(th_abd))^2;
sig = -p/2+sqrt((p/2)^2-q);
%sig = -p/2-sqrt((p/2)^2-q)
L = sig*L;

A = [(x_abd*(1-eps^2)+eps*L)*cosd(alpha)+y_abd*sind(alpha);...
    -(x_abd*(1-eps^2)+eps*L)*sind(alpha)+y_abd*cosd(alpha);...
    z_abd];

% gradient of surface
gradS = A/(r_abd/(2*L));

n = gradS'/norm(gradS);



end

