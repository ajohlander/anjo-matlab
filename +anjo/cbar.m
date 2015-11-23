function [hcb] = cbar(AX)
%ANJO.CBAR One colorbar for several panels.
%   
%   hcb = ANJO.CBAR(AX) Creates a colorbar that spans the right side of the
%   panels in axes vector AX. Automatically updates all panels to have the
%   same color limits.

n = length(AX);
width = 0.0400;

%[left, bottom, width, height]

bottom = 1;
top = 0;
for i = 1:n
    b = AX(i).Position(2);
    t = sum(AX(i).Position([2,4]));
    if b<bottom
        bottom = b;
    end
    if t>top
        top = t;
    end 
end

hcb = colorbar(AX(1));
left = hcb.Position(1);

ax_pos = AX(1).Position;
hcb.Position = [left, bottom, width, top-bottom];

% Restore axes position and update width of other.
for i = 2:n
    AX(i).Position(3) = ax_pos(3);
end

% Matlab is stupid, wierdest hack I have ever done.
pause(0.01)
while(AX(1).Position(3) ~= ax_pos(3))
    AX(1).Position = ax_pos;
end

% Update clim for all axes
clim = [+Inf, -Inf];

for i = 1:n
    cl = AX(i).CLim;
    
    if clim(1)>cl(1)
        clim(1) = cl(1);
    end
    if clim(2)<cl(2)
        clim(2) = cl(2);
    end
end

for i = 1:n
    AX(i).CLim = clim;
end

end

