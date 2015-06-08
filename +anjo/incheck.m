function [out] = incheck(varargin)
%ANJO.INCHECK Matches inputs to parameters.
%
%   paramval = ANJO.INCHECK(inp,A,B,...) Returns parameter values given
%   input vector or cell inp and vector or cell lists of possible
%   parameters A,B,... . Returns parameters in the order same order as
%   parameter lists.
%
%   Use cells if one or more parameters are defined by a string. Otherwise,
%   vectors are fine.


inp = varargin{1};  % First is a unsorted list of inputs.
N = length(varargin); % Number of possible parameters
n = length(inp);    % Number of given inputs

isc = iscell(inp); % Is a cell?

% If not found, returns NaN
if(isc) %Output is cell if input is
    out = repmat({NaN},1,N-1);
else % Otherwise a vector
    out = nan(1,N-1);
end

for i = 1:n
    for j = 2:N
        parvec = varargin{j};
        p = is_in(inp(i),parvec); % Does this work for a cell?
        
        if(length(p) > 1)
            error('Wrong input type.')
        end
        
        if(~isempty(p)) % If found, store and break j-loop
            if isc
                out{j-1} = p{1};
            else
                out(j-1) = p;
            end
            break
        end
        
    end
end

end

function out = is_in(x,y)
% Is x in y? Returns x if it is, otherwise empty cell or matrix.

out = x(ismember(x,y));

end
