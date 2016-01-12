function [] = panel_gap(AX,d)
%ANJO.PANEL_GAP Creates gap between panels
%   
%   ANJO.PANEL_GAP(AX) Acts on axes AX instead of current figure.
%
%   ANJO.PANEL_GAP(...,d) Specify gap d, where d is the gap width in
%   fraction of panel height. Default is 0.05.


% SHOULD SORT AXES ON POSITION(2)
if nargin == 0
    f = gcf;
    AX = findall(f.Children,'Type','Axes');
    d = 0.05;
elseif nargin == 1
    if ishandle(AX(1))
        d = 0.05;
    else
        d = AX;
        f = gcf;
        AX = findall(f.Children,'Type','Axes');
    end
end

N = length(AX);
h = AX(1).Position(4);
u1 = AX(1).Position(2);
D = d*h;

H = u1+h-AX(end).Position(2);
hp = (H-(N-1)*D)/N;

up = zeros(1,N);

up(1) = u1+h-hp;

AX(1).Position(2) = up(1);
AX(1).Position(4) = hp;


for n = 2:N
    ax = AX(n);
    
    up(n) = up(1)-(D+hp)*(n-1);
    
    ax.Position(2) = up(n);
    ax.Position(4) = hp;
    
end

end

