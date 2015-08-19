function [index] = fci(num,vec,varargin)
%ANJO.FCI Finds relevant index of a vector
%   
%   index = ANJO.FCI(num, vec) Returns the index of the vector
%   vec where vec is the closest to the number num. vec must be increasing,
%   num can be a vector or a scalar.
%
%   index = ANJO.FCI(num, vec, mode) Define how out of bounds number are
%   handled. 
%
%   Modes:
%       'ext'   - Out of numbers outside the domain of vec is set to the
%               extreme values: 1 or n = length(vec). This is the default
%               mode.
%       'nan'   -  Out of numbers outside the domain of vec is set to NaN.
%
%   Function used to be called: anjo.find_closest_index. This version is
%   vectorized and has much better performance.


% Possible pararmeters, default is the first element.
pm = {'ext','nan'};

% Get parameters, deafult if not set.
mode = anjo.incheck(varargin,pm);

n = length(vec);
maxV = max(vec);
minV = min(vec);

% Vector of indicies
Y = 1:n;

index = interp1(vec,Y,num,'nearest');

% Handles out of bound numbers.
switch mode
    case 'ext'
        index(num<minV) = 1;
        index(num>maxV) = n;
    %Indices are set to NaN by the interp1 function.
end
end