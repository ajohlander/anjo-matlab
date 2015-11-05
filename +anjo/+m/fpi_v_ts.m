function [out] = fpi_v_ts(varargin)
%ANJO.M.FPI_V_TS Plot ion data as a function of velocity and time.
%
%   ANJO.M.FPI_V_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_V_TS(F) Spectrogram with v_x on the y-axis. Integrated over
%   v_y and v_z.
%
%   ANJO.M.FPI_V_TS(F,yd) Specify what is on the y-axis.
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
if nargin == 1+ish
    yd = 'x';
else
    yd = varargin{2+ish};
end

%% Data handling

F4d = double(F.data);
% Format of F4d is [t,E,phi,th]

[etab,phi,th] = anjo.m.fpi_vals;
u = irf_units;
v = sqrt(2.*etab.*u.e./u.mp)./1e3;

%vf = [-fliplr(v),v];
vf = linspace(-max(v),max(v),64);

nTh = length(th);
nPhi = length(phi);
nEn = length(etab);
nt = size(F.data,1);

f = [];
f.t = F.time.epochUnix;
f.p = zeros(nt,nEn*2);
f.f = vf*1e3;


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


vp = zeros(1,4);

for i = 1:nTh
    for j = 1:nPhi
        for k = 1:nEn
            [vp(1),vp(2),vp(3)] = sph2cart(phi(j)*pi/180,th(i)*pi/180,v(k));
            if idv == 4
                vp(4) = sqrt(vp(2).^2+vp(3).^2);
            end
            idx = anjo.fci(vp(idv),vf,'ext');
            f.p(:,idx) = f.p(:,idx)+F4d(:,k,j,i)*cosd(th(i));
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

