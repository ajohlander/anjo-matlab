function [out] = plot_b(varargin)
%ANJO.M.PLOT_B Plots B-field with the correct labels.
%   
%   AX = ANJO.M.PLOT_B(B1,...,BN) Plots any number of magnetic field
%   TSeries in a new figure. Returns axes handle AX.
%
%   ANJO.M.PLOT_B(AX,...) Plots in axes AX.


%% Input
if ishandle(varargin{1}) && strcmpi(varargin{1}.Type,'axes')
    AX = varargin{1};
    axes_input = 1;
else
    AX = anjo.afigure;
    axes_input = 0;
end
n = nargin-axes_input;
B = cell(1,n);
for i = 1:n
    B{i} = varargin{i+axes_input};
end


%% Plotting
if n>=2
    hold(AX,'on')
end

name = B{1}.name;
comp = name(end);

switch comp
    case {'x','y','z'}
        var_lab = ['$B_{',comp,'}$'];
    case '|'
        var_lab = '$|\textbf{B}|$';
    otherwise
        var_lab = '$B$';
end

irf.log('w',['Plotting variable: ', name])
for i = 1:n
    irf_plot(AX,B{i})
end


%% Label
units = B{1}.units;
if isempty(units)
    units = 'nT';
end
anjo.label(AX,[var_lab,' [', units, ']'])

if ~axes_input && nargout>0
    out = AX;
end

end