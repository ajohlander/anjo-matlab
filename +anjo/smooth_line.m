function [varargout] = smooth_line(X,Y,method,N)
%PLOT_SMOOTH_LINE Mine is better.

if nargin == 2 
    method = 'pchip';
    N = 1e3;
elseif nargin == 3
    if isnumeric(method)
        N = method;
        method = 'pchip';
    else
        N = 1e3;
    end
end
     
x = linspace(min(X),max(X),N);
y = interp1(X,Y,x,method);

if nargout == 2
    varargout{1} = x;
    varargout{2} = y;
else
    varargout{1} = [x',y'];
end
end