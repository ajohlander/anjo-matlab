function out = fpi_plot_ts(varargin)
%ANJO.M.FPI_PLOT_PROJ Plots particle data as a function of time.
%   
%   ANJO.M.FPI_PLOT_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_PLOT_TS(F,t) Spectrogram with energy on the y-axis.
%   Averaged over polar and azimuthal angle.
%
%   ANJO.M.FPI_PLOT_TS(...,yd) Specify what is on the y-axis.
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
f.t = F.time.epochUnix;
F4d = F.data;
% Format of F4d is assumed to be [t,E,phi,th]


% Guess all values in one line!!!
[th,phi,etab,~] = anjo.m.fpi_vals;


switch yd
    case 'e'
        % Average over theta and phi
        F3d = avg_over_pol(F4d,th);
        %F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,3)); % [t,E]
        
        f.f = etab*1e3;
        ylab = 'Energy [eV]';

    case 'th'
        F3d = squeeze(mean(F4d,3)); % [t,E,th]
        F2d = squeeze(mean(F3d,2)); % [t,th]
        
        f.f = th;
        ylab = '$\theta$ [$^\circ$]';
        
    case 'phi'
        F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,2)); % [t,phi]
        
        f.f = phi;
        ylab = '$\phi$ [$^\circ$]';
        
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


function F3d = avg_over_pol(F4d,th)

s = size(F4d);
F3d = zeros(s(1),s(2),s(3));
for i = 1:16
    fval = squeeze(F4d(:,:,:,i))*cosd(th(i));
    F3d = F3d+fval/16;
end

end

