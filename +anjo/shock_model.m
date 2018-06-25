function [xsh,ysh,x0,y0,alpha] = shock_model(r,shModel,alpha0,N)
% Lets do 2D!



if nargin<3
    alpha0 = 3.5; % placeholder
end
if nargin<4
    N = 100;
end

u = irf_units;
% sc position in GSE (or GSM or whatever) in Earth radii
if isnumeric(r) % just a vector
    if length(r) == 2 % x,y
        rsc = r'/u.RE*1e3;
        gamma = 0; % elevation angle from ecliptic plane
    elseif length(r) == 3 % x,y,z
        rsc = [r(1);sign(r(2))*sqrt(sum(r(2:3).^2))]/u.RE*1e3; % bang bang 
        gamma = atand(r(3)/r(2)); % elevation angle from ecliptic plane
    end     
end


switch lower(shModel)
    case 'slho'
        x0 = 3.0;
        y0 = 0;
        eps = 1.16;
        alpha = alpha0;
        L = 23.3;
    case 'farris'
        x0 = 0;
        y0 = 0;
        eps = 0.81;
        alpha = 3.8;
        L = 24.8;
    case 'fa4o'
        x0 = 3.4;
        y0 = 0.3;
        eps = 1.02;
        alpha = 4.8;
        L = 22.3;
    case 'fan4o'
        x0 = 4.6;
        y0 = 0.4;
        eps = 1.05;
        alpha = 5.2;
        L = 20.5;
    otherwise
        error('unknown model')
end

% rotation matrix
R = [cosd(alpha),-sind(alpha);sind(alpha),cosd(alpha)];

% offset from GSE
r0 = [x0;y0];

% might be right
alpha = alpha*cosd(gamma);

% Calculate sigma
% sc position in the natural system (cartesian)
rp = @(sig)R*rsc-sig.*r0;
% sc polar angle in the natural system
thp = @(sig)cart2pol([1,0]*rp(sig),[0,1]*rp(sig)); % returns angle first
% minimize |LH-RH| in eq 10.22
fval = @(sig)abs(sig.*L./sqrt(sum(rp(sig).^2,1))-1-eps*cos(thp(sig)));

% find the best fit for sigma
sig0 = fminsearch(fval,0);  
% make sure it finds the largest one
sig0 = fminsearch(fval,sig0*2);  

% array of abberated angles
% the limits are emprical, for elliptic conic section it could be anything
thpArr = linspace(-140,140,N);

% array of radii
rpArr = sig0*L./(1+eps*cosd(thpArr));

% array of vectors
xsh = zeros(1,N);
ysh = zeros(1,N);
%thv = zeros(1,N);
for ii = 1:N % should be vectorized
    rpv = [rpArr(ii)*cosd(thpArr(ii));rpArr(ii)*sind(thpArr(ii))];
    rv = R\(rpv+sig0*r0);
    %thv(ii) = atand(rv(2)/rv(1));
    xsh(ii) = rv(1); ysh(ii) = rv(2);
    %[xsh(ii),ysh(ii)] = pol2cart(thv(ii)
end

disp('was it?')

end