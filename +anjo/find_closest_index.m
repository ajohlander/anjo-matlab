function [index] = find_closest_index(num,vec)
%ANJO.FIND_CLOSEST_INDEX Finds relevant index of a vector
%   index = ANJO.FIND_CLOSEST_INDEX(num, vec) returns the index of the vector
%   vec where vec is the closest to the number num. vec must be increasing.

index = find(num>=vec, 1, 'last' );

if index == length(vec)
    return;
elseif(num-vec(index) >= vec(index+1)-num)
    index = index+1;
end

if isempty(index)
    index = 1;
end

end

