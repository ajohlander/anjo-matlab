function out = fpi_plot_ts(varargin)
%ANJO.M.FPI_PLOT_PROJ Plots particle data as a function of time.
%   
%   ANJO.M.FPI_PLOT_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_PLOT_PROJ(F,t) Spectrogram with energy on the y-axis.
%   Averaged over polar and azimuthal angle.
%
%   ANJO.M.FPI_PLOT_PROJ(...,yd) Specify what is on the y-axis.
%
%   yd: 'e', 'th', 'phi'.
%
%   Very unfinished.
%
%   TODO: Figure out angles and energies.


%% Input
if nargin < 2
    error('Too few input pararmeters.')
end
if ishandle(varargin{1})
    ish = 1;
    AX = varargin{1};
    F = varargin{2};
else
    ish = 0;
    F = varargin{1};
    AX = anjo.afigure;
end

pyd = {'e','th','phi'};
if nargin == 2+ish
    yd = anjo.incheck(varargin(2+ish),pyd);
else
    yd = pyd{1};
end

%% Data handling

f = [];
f.t = irf_time(F.time.data,'ttns>epoch');
F4d = F.data;
% Format of F4d is assumed to be [t,E,phi,th]

etab = logspace(0,5,32)*1e3;
% Guess the elevation (or polar??) angle
th = linspace(-90,90,16);
%th = zeros(1,16);
% Guess the azimuth
phi0 = 165;
phi = linspace(phi0,phi0+360,32);


switch yd
    case 'e'
        % Average over theta and phi
        F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,3)); % [t,E]
        
        f.f = etab;
        ylab = 'Energy [a.u.]';

    case 'th'
        F3d = squeeze(mean(F4d,3)); % [t,E,th]
        F2d = squeeze(mean(F3d,2)); % [t,th]
        
        f.f = th;
        ylab = '$\theta$ [guess]';
        
    case 'phi'
        F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,2)); % [t,phi]
        
        f.f = phi;
        ylab = '$\phi$ [not really]';
        
    otherwise
        error('Why do you come here?')
end

f.p = F2d;

irf_spectrogram(AX,f);
irf_timeaxis(AX)

anjo.label(AX,ylab)

if strcmpi(yd,'e')
    AX.YScale = 'log';
end


if nargout == 1
    out = F2d;
end

end

