function [divB,dBxDx,dByDy] = get_divB(x,y,B,diffOrder)
%GET_VECPOT Summary of this function goes here
%   Detailed explanation goes here


if nargin == 3
    diffOrder = 1;
end


nx = length(x);
ny = length(y);

if diffOrder == 1
    
    dBxDx = zeros(nx-1,ny-1);
    dByDy = zeros(nx-1,ny-1);
    divB = zeros(nx-1,ny-1);
    for i = 1:nx-1
        for j = 1:ny-1
            dBxDx(i,j) = (B(i+1,j,1)-B(i,j,1))/(x(i+1)-x(i));
            dByDy(i,j) = (B(i,j+1,2)-B(i,j,2))/(y(j+1)-y(j));
            divB(i,j) = dBxDx(i,j)+dByDy(i,j);
        end
    end
    
    
elseif diffOrder == 2
    dBxDx = zeros(nx-2,ny-2);
    dByDy = zeros(nx-2,ny-2);
    divB = zeros(nx-2,ny-2);
    for i = 1:nx-2
        for j = 1:ny-2
            dBxDx(i,j) = (B(i+2,j,1)-B(i,j,1))/(x(i+2)-x(i));
            dByDy(i,j) = (B(i,j+2,2)-B(i,j,2))/(y(j+2)-y(j));
            divB(i,j) = dBxDx(i,j)+dByDy(i,j);
        end
    end
    
    
end

