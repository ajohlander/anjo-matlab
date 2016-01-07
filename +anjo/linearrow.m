function [out] = linearrow(AX,varargin)
%LINEARROW Draws arrows along a line
%
%   ANJO.LINEARROW(AX,...) Acts on axis handle AX instead of current axis
%
%   ANJO.LINEARROW(x,y,N) Draws N arrows along the line defined by x and y.
%   If N is omitted, 10 arrows are drawn. Axis is set to equal by default.
%
%   q = ANJO.LINEARROW(x,y,N) Also returns handle for the arrows.
%
%   See also: ANJO.TRIANGLE, ANJO.MARKER


%% Input
hInp = 1;
if(isnumeric(AX))
    x = AX;
    AX = gca;
    hInp = 0;
end

if(nargin >= 2+hInp)
    if(hInp)
        x = varargin{1};
    end
    y = varargin{1+hInp};
    if(nargin == 2+hInp)
        N = 10;
    else
        N = varargin{2+hInp};
    end
end

if nargin==4+hInp
    arf = varargin{3+hInp};
else
    arf = 60;
end

% If column vector, transpose
if(iscolumn(x))
    x = x';
end

if(iscolumn(y))
    y = y';
end 

%% Get position and angles for the arrows
np = length(x);

if(length(y) ~= np)
    error('Vectors not the same length.')
end

z = zeros(1,np);
len = linelength(x,y,z);

avp = len/(N+1)*(1:N);


lenAr = zeros(1,np);
for i = 1:np
    lenAr(i) = linelength(x(1:i),y(1:i),z(1:i));
end

%---- Hack method-----
aip = zeros(1,N);
for i = 1:N
    aip(i) = anjo.fci(avp(i),lenAr);
end
%---------------------

% Get angles
th = getTh(x,y,aip);

%% Plot arrows

s = (max(y)-min(y))/arf;
q = anjo.triangle(AX,x(aip),y(aip),th,s);
axis(AX,'equal')

%% Output
if(nargout == 1)
    out = q;
end

end


function th = getTh(x,y,ind)
% GETTH Returns theta angle between arrow and [0,1,0];

n = length(ind);
th = zeros(1,n);
for i = 1:n
    if(ind(i)==1)
        di = [ind(i),ind(i)+1];
    elseif(ind(i)==length(x))
        di = [ind(i)-1,ind(i)];
    else
        di = [ind(i)-1,ind(i)+1];
    end
    r = [diff(x(di)),diff(y(di))];
    
    th(i) = acosd(dot(r,[0,1])/norm(r));
    if(r(1) > 0)
        th(i) = 360-th(i);
    end
end

end

function [len] = linelength(x,y,z)
%LINELENGTH Calculate length of a line.
%   
%   len = LINELENGTH(x,y,z) Returns length, z can be omitted,

n = length(x);

if(nargin == 2)
    z = zeros(1,n);
end

if(length(y) ~= n || length(z) ~= n)
    error('Vectors not the same length.')
end

len = sum(sqrt(diff(x).^2+diff(y).^2+diff(z).^2));

end