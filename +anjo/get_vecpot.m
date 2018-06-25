function [Az] = get_vecpot(x,y,B)
%GET_VECPOT Summary of this function goes here
%   Detailed explanation goes here

nx = length(x);
ny = length(y);

Az = zeros(nx,ny);

B = fliplr(B);

% do it forwards
Az(:,1) = -cumtrapz(x,B(:,1,2));

for i = 1:nx
    Az(i,:) = -cumtrapz(y,B(i,:,1))+Az(i,1);
end

% % do it backward
% Az(:,end) = -cumtrapz(x,B(:,end,2));
%
% for i = 2:nx
%     Az(i,:) = cumtrapz(fliplr(y),B(i,:,1))+Az(i,end);
% end

Az = fliplr(Az);



end

