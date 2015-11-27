function out = fpi_plot_ts(varargin)
%ANJO.M.FPI_PLOT_PROJ Plots particle data as a function of time.
%   
%   ANJO.M.FPI_PLOT_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_PLOT_TS(F) Spectrogram with energy on the y-axis.
%   Averaged over polar and azimuthal angle.
%
%   ANJO.M.FPI_PLOT_TS(F,yd,first_parity) Specify what is on the y-axis.
%   first_parity determines in which order the energy tables are used.
%
%   yd: 'e', 'th', 'phi', 'f'.
%
%   See also: ANJO.M.FPI_PART_DIST
%
%   TODO: Figure out angles.


%% Input
if ishandle(varargin{1})
    ish = 1;
    AX = varargin{1};
    F = varargin{2};
else
    ish = 0;
    F = varargin{1};
    AX = anjo.afigure;
end

pyd = {'e','th','phi','f'};
if nargin >= 2+ish
    if ischar(varargin{2+ish})
        yd = varargin{2+ish};
        if nargin == 3+ish
            first_parity = varargin{3+ish};
        else
            first_parity = 0;
        end
    else
        first_parity = varargin{2+ish};
    end
else
    yd = pyd{1};
    first_parity = 0;
end

switch yd
    case pyd{1}
        irf.log('w','Plotting particle data as a function of energy.')
    case pyd{2}
        irf.log('w','Plotting particle data as a function of elevation angle.')
    case pyd{3}
        irf.log('w','Plotting particle data as a function of azimuthal angle.')
    case pyd{4}
        irf.log('w','Plotting particle data as a function of phase space density.')
end


%% Data handling

f = [];
f.t = F.time.epochUnix;
F4d = F.data;
nt = size(F4d,1);
% Format of F4d is [t,E,phi,th]

% Guess all values in one line!!!
[e0,e1,phi,th] = anjo.m.fpi_vals;

% Phi handling
if isfield(F.userData,'phi') && ~isempty(F.userData.phi)
    phi = double(F.userData.phi.data)-180;
end

switch yd
    case 'e'
        % Average over theta and phi
        F3d = avg_over_pol(F4d,th);
        %F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,3)); % [t,E]
        
        f.f = zeros(nt,32);
        if first_parity == 0
            f.f(1:2:end,:) = repmat(e0,floor(nt/2)+mod(nt,2),1);
            f.f(2:2:end,:) = repmat(e1,floor(nt/2),1);
        else
            f.f(1:2:end,:) = repmat(e1,floor(nt/2)+mod(nt,2),1);
            f.f(2:2:end,:) = repmat(e0,floor(nt/2),1);
        end
        f.f_label = 'eV'; 
        ylab = 'Energy [eV]';

    case 'th'
        F3d = squeeze(mean(F4d,3)); % [t,E,th]
        F2d = squeeze(mean(F3d,2)); % [t,th]
        
        f.f = th;
        f.f_label = 'deg'; 
        ylab = '$\theta$ [$^\circ$]';
        
    case 'phi'
        F3d = avg_over_pol(F4d,th); %[t,E,phi]
%         F3d = squeeze(mean(F4d,4)); % [t,E,phi]
        F2d = squeeze(mean(F3d,2)); % [t,phi]

        f.f = phi;
        f.f_label = 'deg'; 
        ylab = '$\varphi$ [$^\circ$]';
        
    case 'f'
        F3d = avg_over_pol(F4d,th); %[t,E,phi]
        F2d = squeeze(mean(F3d,2)); % [t,phi]
        F1d = squeeze(mean(F2d,2)); % [t]

        ylab = '$\log{F}$ [s$^3$cm$^{-6}$]';
    otherwise
        error('Why do you come here?')
end

if strcmpi(yd,'f')
    irf_plot(AX,[f.t,double(F1d)]);
    AX.YScale = 'log';
else
    f.p = double(F2d)*1e30;
    irf_spectrogram(AX,f);
    irf_timeaxis(AX)
    
    if strcmpi(yd,'e')
        AX.YScale = 'log';
        AX.YTick = [1e2,1e3,1e4];
    end
    
%     hcb = colorbar(AX);
%     anjo.label(hcb,'$\log{F}$ [s$^3$cm$^{-6}$]')
end

anjo.label(AX,ylab)

if nargout == 1
    if strcmpi(yd,'f')
        out = F1d;
    else
        out = F2d;
    end
end

end


function F3d = avg_over_pol(F4d,th)
% returns matrix of form [t,E,phi]
s = size(F4d);
F3d = zeros(s(1),s(2),s(3));
for i = 1:length(th)
    fval = squeeze(F4d(:,:,:,i))*cosd(th(i));
    F3d = F3d+fval/16;
end

end

