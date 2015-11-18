function [out] = fpi_v_ts(varargin)
%ANJO.M.FPI_V_TS Plot ion data as a function of velocity and time.
%
%   ANJO.M.FPI_V_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_V_TS(F) Spectrogram with v_x on the y-axis. Integrated over
%   v_y and v_z.
%
%   ANJO.M.FPI_V_TS(F,yd,first_parity) Specify what is on the y-axis.
%   first_parity determines in which order the energy tables are used.
%
%   yd: 'x', 'y', 'z', 't'
%
%   See also: ANJO.M.FPI_PLOT_TS, ANJO.M.FPI_PLOT_PROJ
%
%   TODO: Is there a reasonable way to average data instead of integrating?


%% Input
ish = ishandle(varargin{1});
if ish
    AX = varargin{1};
else
    AX = anjo.afigure(1,[10,10]);
end
F = varargin{1+ish};

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
    yd = 'x';
    first_parity = 0;
end

%% Data handling

F4d = double(F.data);
% Format of F4d is [t,E,phi,th]
nt = size(F4d,1);

[e0,e1,phi,th] = anjo.m.fpi_vals;
u = irf_units;

emat = zeros(nt,32);
if first_parity == 0
    emat(1:2:end,:) = repmat(e0,floor(nt/2),1);
    emat(2:2:end,:) = repmat(e1,floor(nt/2),1);
else
    emat(1:2:end,:) = repmat(e1,floor(nt/2),1);
    emat(2:2:end,:) = repmat(e0,floor(nt/2),1);
end

v = sqrt(2.*emat.*u.e./u.mp)./1e3;

% Assumes n >= 3.
vf = linspace(-max(v(first_parity+2,:)),max(v(first_parity+2,:)),64);

nTh = length(th);
nPhi = length(phi);
nEn = length(e0);

f = [];
f.t = F.time.epochUnix;
f.p = zeros(nt,nEn*2);
f.f_label = 'velocity [km/s]';
f.f = vf;


switch yd
    case 'x'
        idv = 1;
        ylab = '$v_x$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vx.')
    case 'y'
        idv = 2;
        ylab = '$v_y$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vy.')
    case 'z'
        idv = 3;
        ylab = '$v_z$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vz.')
    case 't'
        idv = 4;
        ylab = '$v_t$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of sqrt(vy^2+vz^2).')
end



%odd
for m = 1:2
    vp = zeros(floor(nt/2),4);
    for i = 1:nTh
        for j = 1:nPhi
            for k = 1:nEn
                [vp(1),vp(2),vp(3)] = sph2cart(phi(j)*pi/180,th(i)*pi/180,v(m,k));
                if idv == 4
                    vp(4) = sqrt(vp(2).^2+vp(3).^2);
                end
                idx = anjo.fci(vp(idv),vf,'ext');
                f.p(m:2:end,idx) = f.p(m:2:end,idx)+F4d(m:2:end,k,j,i)*cosd(th(i));
            end
        end
    end
end
%% Plotting

irf_spectrogram(AX,f);
irf_timeaxis(AX)

hcb = colorbar(AX);
anjo.label(hcb,'$\log{F}$ [s$^3$cm$^{-6}$]')

anjo.label(AX,ylab)

if nargout == 1
    out = f;
end

end

