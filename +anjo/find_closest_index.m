function [index] = find_closest_index(num,vec)
%ANJO.FIND_CLOSEST_INDEX Finds relevant index of a vector
%   
%   index = ANJO.FIND_CLOSEST_INDEX(num, vec) returns the index of the vector
%   vec where vec is the closest to the number num. vec must be increasing,
%   num can be a vector or a scalar.

nnum = length(num);
index = zeros(1,nnum);

for i = 1:nnum
    ind = find(num(i)>=vec, 1, 'last' );
    if isempty(ind)
        index(i) = 1;
    elseif ind == length(vec)
        index(i) = ind;
    elseif(num(i)-vec(ind) >= vec(ind+1)-num(i))
        index(i) = ind+1;
    else
        index(i) = ind;
    end
    
end
end

