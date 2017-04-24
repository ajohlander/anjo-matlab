function [Bd0,Vd0,nd0,Pd0] = rankhug(Bu,Vu,nu,Pu)
%ANJO.RANKHUG Solves the Rankine-Hugoniot relations.
%
%   [Bd,Vd,nd,Pd] = ANJO.RANKHUG(Bu,Vu,nu,Pu)
%
% Ma must be 1.3 or higher for thBn = 90.
% 
%
%                         ug
%                        b
%                       g           bug
%                       u        bug
%       bugbug          b       g
%             bug      bugbug bu
%                bug  bugbugbugbugbugbug
%   bug   bug   bugbugbugbugbugbugbugbugb
%      bug   bug bugbugbugbugbugbugbugbugbu
%    bugbugbugbu gbugbugbugbugbugbugbugbugbu
%   bugbugbugbug
%    bugbugbugbu gbugbugbugbugbugbugbugbugbu
%      bug   bug bugbugbugbugbugbugbugbugbu
%   bug   bug  gbugbugbugbugbugbugbugbugb
%                bug  bugbugbugbugbugbug
%             bug      bugbug  bu
%       bugbug          b        g
%                       u         bug
%                       g            bug
%                        b
%                         ug
%


% Solve Bd, Vd and nd for a range of rs
N = 1000;
rr = linspace(1.01,4.01,N);

% initiate notation
Vux = Vu(1);
% Vut = [0,Vu(2:3)];

Bux = Bu(1);
Buy = Bu(2);

% real units
u = irf_units;
mu0 = u.mu0;
m = u.mp;

gamma = 5/3;
rg = gamma/(gamma-1);

% trivial function, only one solution
Bdx = Bux;


% Annoying function corresponding to RH?
%f4 = @(x)m*nu*Vux^2+Pu+Buy^2/(2*mu0)-m*x(4)*x(2)^2-x(5)-x(1)^2/(2*mu0);
f5 = @(Bdy,Vdx,Vdy,nd,Pd)m*nu*Vux*(Vux^2/2+rg*Pu/(m*nu)+(Bux^2+Buy^2)/(mu0*m*nu))...
    -Vux*Bux^2/mu0...
    -m*nd.*Vdx.*((Vdx.^2+Vdy.^2)/2+rg*Pd./(m*nd)+(Bdx^2+Bdy.^2)./(mu0*m*nd))...
    +(Vdx*Bdx+Vdy.*Bdy)*Bdx/mu0;

[Bdy,Vdx,Vdy,nd,Pd] = par_analytic(Bux,Buy,Vux,nu,Pu,rr);

f5val = f5(Bdy,Vdx,Vdy,nd,Pd);

% figure;
% plot(rr,f5val)
% grid on

% brute force method, I can't think of a better way...
r = interp1(f5val,rr,0,'nearest'); % nearest option is not ideal but avoids bugs

% get solution for best r
[Bdy0,Vdx0,Vdy0,nd0,Pd0] = par_analytic(Bux,Buy,Vux,nu,Pu,r);

Bd0 = [Bdx,Bdy0,0];
Vd0 = [Vdx0,Vdy0,0];

end

function [Bdy,Vdx,Vdy,nd,Pd] = par_analytic(Bux,Buy,Vux,nu,Pu,rr)
%     /\__/\
%    /`    '\
%  === 0  0 ===
%    \  --  /
%   /        \
%  /          \
% |            |
%  \  ||  ||  /
%   \_oo__oo_/#######o

% real units
u = irf_units;
mu0 = u.mu0;
m = u.mp;

% trivial function, only one solution
Bdx = Bux;

% loop with analytic solotion, could probs be vectorized

nd = rr.*nu;
Vdx = Vux./rr;

Vdy = (-Bux.*Buy./mu0+Bdx.*Buy.*Vux./(Vdx.*mu0))./(nd.*m.*Vdx-Bdx^2./(Vdx*mu0));
Bdy = (Vdy.*Bdx+Vux*Buy)./Vdx;

% Analytically solve Pd from f4
Pd = m*nu*Vux^2+Pu+Buy^2/(2*mu0)-m*nd.*Vdx.^2-Bdy.^2/(2*mu0);

end
