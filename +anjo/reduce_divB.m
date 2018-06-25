function [B] = reduce_divB(x,y,Bin)
%GET_VECPOT Summary of this function goes here
%   Detailed explanation goes here

nx = length(x);
ny = length(y);


B = Bin;

for i = 1:nx-1
    for j = 1:ny-1
        
        dx = x(i+1)-x(i);
        dy = y(j+1)-y(j);
        
        % get local divB
        [divB,~,~] = anjo.get_divB(x(i:i+1),y(j:j+1),B(i:i+1,j:j+1,:));
        
        if isnan(divB)
            error('qui?')
        end
        
        % new Bx if By is fixed
        %fooBx = B(i+1,j,1)-dx*(0-(B(i,j+1,2)-B(i,j,2))/dy);
        % guess lots of values of new Bx
        % newBxv = linspace(B(i,j,1),fooBx,100);
        newBxv = linspace(-200,+200,1e5);
        
        % new By given new Bx array
        newByv = B(i,j+1,2)+dy*((B(i+1,j,1)-newBxv)./dx);
        
        % error function
        R = (newBxv-B(i,j,1)).^2+(newByv-B(i,j,2)).^2;
        idB = find(R==min(R),1);
        
        B(i,j,1) = newBxv(idB);
        B(i,j,2) = newByv(idB);

    end
end




end

