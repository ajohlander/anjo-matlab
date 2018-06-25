function [outp] = rankhug(inp)
%ANJO.RANKHUG Solves the Rankine-Hugoniot relations for fast mode shocks.
%
%   down_param = ANJO.RANKHUG(up_param) Returns structure with downstream
%   parameters.
%
%   Fields in input:
%       Mf      -   Fast Mach number
%       th      -   Shock normal angle
%       beta    -   Plasma beta
%       optional:
%       gamma   -   Heat capacity ratio (5/3 if omitted)
%       rr      -   Array of compression ratios to test   
%       out     -   Cell of strings specifying outputs
% 
%   Outputs (Downstream parameters):
%       Mdf     -   Fast Mach number
%       thd     -   Shock angle
%       betad   -   Plasma beta
%       Mda     -   Alfven Mach number
%       MdI     -   Intermediate Mach number
%       Mds     -   Sonic Mach number
%       f4n     -   Normalized energy difference |dW|/Wu given rr
%       csd
%       vda
%       vdf
%       Bd
%       Vd      -   Downstream speed in upstream Va
%       Vd_Vu   -   In units of the upstream velocity
%       nd      -   nu is always 1
%       Pd
%       
%   Upstream parameters are (see code for the rest):
%       Bu = [cosd(th),sind(th),0]
%       Vu = [Mf*vms(th),0,0]
%       nu = 1;
%       



%% Input
% Set parameters
Mf = inp.Mf;
th = inp.th;
beta = inp.beta;


if isfield(inp,'gamma')
    gamma = inp.gamma;
else
    gamma = 5/3;
end
rg = gamma/(gamma-1);

if ~isfield(inp,'out'); inp.out = {'full'}; end
if ~iscell(inp.out); inp.out = {inp.out}; end


% set dimensionless parameters
Bu = 1; %
nu = 1;

Bn = Bu*cosd(th);
But = Bu*sind(th);

%% Set parameters
va = 1; % means that mu0*m = 1. Let's set them both to 1.
mu0 = 1;
m = 1;

cs = sqrt(gamma/2*beta)*va; % sound speed
cms = sqrt(va^2+cs^2);
vms = sqrt(cms^2/2+sqrt(cms^4/4-va^2*cs^2*cosd(th)^2));

Vu = Mf*vms;

Pu = beta*Bu^2/2;


%% Functions
% analytical solutions
nd = @(r)nu*r;
Vdn = @(r)Vu./r;
%Vdt = @(r)(-Bn.*But./mu0+Bn.*But.*Vu./(Vdn(r).*mu0))./(nd(r).*m.*Vdn(r)-Bn^2./(Vdn(r)*mu0));
Vdt = @(r)(Bn.*But.*(Vu./Vdn(r)-1))./(nd(r).*m.*mu0.*Vdn(r)-Bn^2./Vdn(r));
Bdt = @(r)(Vdt(r).*Bn+Vu*But)./Vdn(r);
Pd = @(r)m*nu*Vu^2+Pu+(But^2)/(2*mu0)-m*nd(r).*Vdn(r).^2-(Bdt(r).^2)/(2*mu0);

% energy flux
f4 = @(r)(m*nu*Vu*(Vu^2/2+rg*Pu/(m*nu)+But^2/(mu0*m*nu))...
    -m*nd(r).*Vdn(r).*((Vdn(r).^2+Vdt(r).^2)/2+gamma/(gamma-1)*Pd(r)./(m*nd(r))+Bdt(r).^2./(mu0*m*nd(r)))+(Vdt(r).*Bdt(r))*Bn/mu0);


%% Solve f4(r) = 0
% 

% find zero crossing, only adapted for gamma = 5/3

if isfield(inp,'rr') % user-defined grid
    rr = inp.rr;
else % automatic
    N = 1e5; % number of grid points
%     if Mf>4
%         Mmin = 3;
%         Mmax = 4.1;
%     elseif th > 20
%         Mmin = 1;
%         Mmax = Mf*1.5;
%     elseif th == 0
%         Mmin = 3.5;
%         Mmax = 4.5;
%     else
%         Mmin = Mf;
%         Mmax = Mf*1.8;
%     end
    Mmin = 0.99;
    Mmax = 4.01;
    rr = linspace(Mmin,Mmax,N);
end

f4v = f4(rr);
% find zero crossings
idz = find(f4v(1:end-1).*f4v(2:end)<0);

% test if increasing 
if f4(rr(idz(1)+1))-f4(rr(idz(1)))>0
    idz = idz(1);
else
    % try the next one
    idz = idz(2);
end
r0 = interp1([f4(rr(idz+1)),f4(rr(idz))],[rr(idz),rr(idz+1)],0);

% solve more elegantly
%r = fzero(f4,r0);
% fzero is a sad function
r = r0;


% r0 = 4;

% if Mf == 1 % should not be needed
%     Bd0 = [Bx,Buy,0];
%     Vd0 = [Vu,0,0];
%     nd0 = nu;
%     Pd0 = Pu;
%     return
% end




% Bd0 = [Bn,Bdt(r),0];
% Vd0 = [Vdn(r),Vdt(r),0];
% nd0 = nd(r);
% Pd0 = Pd(r);


%% output

% functions

outp = [];
% special
if strcmpi(inp.out{1},'full')
    inp.out = {'Bd','Vd','nd','Pd','thd','betad','Mdf','MdI','vda','thdVn','f4n','Vd_Vu'}; 
end 

Bd = @(r)[Bn,Bdt(r),0];
Vd = @(r)[Vdn(r),Vdt(r),0];
Vd_Vu = @(r)[Vdn(r),Vdt(r),0]/Vu;

thd = @(r)atand(Bdt(r)/Bn);
betad = @(r)Pd(r)*2*mu0/norm(Bd(r))^2;

thdVn = @(r)atand(Vdt(r)/Vdn(r));

vda = @(r)norm(Bd(r))/sqrt(nd(r)*m*mu0);
cds = @(r)sqrt(gamma*betad(r)/2)*vda(r);
vdf = @(r)(vda(r)^2+cds(r)^2)/2+sqrt((vda(r)^2+cds(r)^2)^2/4-vda(r)^2*cds(r)^2*cosd(thd(r)).^2);
vdt = @(r)sqrt(2*Pd(r)/(m*nd(r))); % ion thermal speed
Mdf = @(r)Vdn(r)/vdf(r);
Mda = @(r)Vdn(r)/vda(r);
Mds = @(r)Vdn(r)/cds(r);
MdI = @(r)Mda(r)*secd(thd(r)); % [Schwartz, 1998] (ISSI book)
Mdt = @(r)Vdn(r)/vdt(r);
f4n = @(r)f4(rr)./(m*nu*Vu*(Vu^2/2+rg*Pu/(m*nu)+But^2/(mu0*m*nu))); %normalized


for k = 1:length(inp.out)
    eval(['outp.',inp.out{k},'=',inp.out{k},'(r);'])
end

% no struct if only one output
fn = fieldnames(outp);
if numel(fn) == 1; outp = outp.(fn{1}); end

% for k = 1:length(inp.out)
% switch inp.out{k} % is case sensitive
%     case 'Bd'
%         out.Bd = [Bn,Bdt(r),0];
%     case 'Vd'
%         out.Vd = [Vdn(r),Vdt(r),0];
%     case 'nd' 
%         out.nd = nd;
%     case 'Pd'
%         out.Pd = Pd;
%     case 'thd'
%         out.thd = ;
%     case 'betad'
%         out.betad = [Vdn(r),Vdt(r),0];
%     case 'Mdf' 
%         out.Mdf = nd;
%     case 'MdI'
%         out.Pd = Pd;
%         
% end
% end
        


% if nargin == 5 && nargout == 5
%     f4na = @(r)m*nu*Vu*(Vu^2/2+rg*Pu/(m*nu)+Buy^2/(mu0*m*nu))...
%     -m*nd(r).*Vdx(r).*((Vdx(r).^2+Vdy(r).^2)/2+gamma/(gamma-1)*Pd(r)./(m*nd(r))+Bdy(r).^2./(mu0*m*nd(r)))+(Vdy(r).*Bdy(r))*Bx/mu0;
% 
%     f4n = f4na(rr)/(m*nu*Vu*(Vu^2/2+rg*Pu/(m*nu)+Buy^2/(mu0*m*nu))); % normalized
% end

end
