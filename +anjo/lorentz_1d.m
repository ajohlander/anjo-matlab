function [vel, xMin, Y] = lorentz_1d(eF,bF,v0,runTime)%,dT,nSlams)
%ANJO.LORENTZ_1D performs test patrticle simulation
%   vel = ANJO.LORENTZ_1D(eF,bF,v0,runTime) Detailed explanation goes here

set_global_E_B(eF,bF);

%n = floor(runTime/dT);
tSpan = [0, runTime];

%vel = zeros(n,4);


xib = max(bF(:,1)); %initial position
xie = max(eF(:,1));

if xib<xie
    x = xib;
else
    x = xie;
end

%xMin = x;


y0 = [x,0,0,v0];


% q = 1.602e-19;
% mi = 1.6726e-27;

% B = get_B_field(bField,x);
% E = get_E_field(eField,x);

[T,Y] = ode45(@lorentz_force,tSpan,y0);

vel = [T,Y(:,4),Y(:,5),Y(:,6)];
xMin = min(Y(:,1));
% 
% for i = 1:n-1
%     v = vel(i,2:4);
%     
%     B = get_B_field(bField,x);
%     E = get_E_field(eField,x);
%     
%     a = q/mi*(E + cross(v,B));
%     
%     v = v + a*dT;
%     x = x-v*nSlams'*dT;
%     
%     if(x<xMin)
%         xMin = x;
%     end
%     
%     vel(i+1,:) = [vel(i,1)+dT, v];
%     
% end


end


function [dy] = lorentz_force(t,y)
%LORENTZ_FORCE Lorem
%   y = [x, y, z, vx, vy, vz]
q = 1.602e-19;
m = 1.67e-27;
%m = m/1836;
eF = get_E_field(y(1));
[bF,inBounds] = get_B_field(y(1));
F = q*(eF+cross([y(4),y(5),y(6)],bF));

dy = zeros(6,1);

if(inBounds)
    dy(1) = y(4);
    % dy(2) = y(5);
    % dy(3) = y(6);
    
    dy(4) = F(1)/m;
    dy(5) = F(2)/m;
    dy(6) = F(3)/m;
else
    disp('lol')
    dy(1) = 0;
    % dy(2) = y(5);
    % dy(3) = y(6);
    
    dy(4) = NaN;
    dy(5) = NaN;
    dy(6) = NaN;
end

end


function [interpE] = get_E_field(x) 
%E Lorem
%   Ipsum

global eField
if(x<min(eField(:,1)) || x>max(eField(:,1)))
    interpE = zeros(1,3);
    %disp('Out of simulation!')
else
    interpE = interp1(eField(:,1),eField(:,2:4),x)/1e3;
    interpE(isnan(interpE)) = 0;
end

end

function [interpB,inBox] = get_B_field(x)
%E Lorem
%   Ipsum

global bField
if(x<min(bField(:,1)) || x>max(bField(:,1)))
    interpB = zeros(1,3);
    inBox = false;
    %disp('Out of simulation!')
else
    interpB = interp1(bField(:,1),bField(:,2:4),x)/1e9;
    inBox = true;
end
end

function set_global_E_B(eF,bF)

global eField
global bField

eField = eF;
bField = bF;
end

