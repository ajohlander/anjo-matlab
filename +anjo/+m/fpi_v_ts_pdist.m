function [out] = fpi_v_ts_pdist(varargin)
%ANJO.M.FPI_V_TS Plot ion data as a function of velocity and time. 
% 
% Works with PDist
%
%   ANJO.M.FPI_V_TS(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_V_TS(F) Spectrogram with v_x on the y-axis. Averaged over
%   v_y and v_z.
%
%   ANJO.M.FPI_V_TS(...,yd) Specify what is on the y-axis. Can be axis name
%   or vector (vector is normalized).
%
%   yd: 'x', 'y', 'z'
%
%   Assumes F.userData.emat exist and is good.
%
%   See also: ANJO.M.FPI_PLOT_TS, ANJO.M.FPI_PLOT_PROJ,
%   ANJO.M.FPI_GET_DISTR


%% Input
ish = ishandle(varargin{1});
if ish
    AX = varargin{1};
else
    AX = anjo.afigure(1,[10,10]);
end
F = varargin{1+ish};

if nargin >= 2+ish
    if ischar(varargin{2+ish}) || length(varargin{2+ish})==3
        yd = varargin{2+ish};
    end
else
    yd = 'x';
end

if ischar(yd)
    switch yd
        case 'x'
            vv = [1,0,0];
            ylab = '$v_x$ [km\,s$^{-1}$]';
            irf.log('w','Plotting particle data as a function of vx.')
        case 'y'
            vv = [0,1,0];
            ylab = '$v_y$ [km\,s$^{-1}$]';
            irf.log('w','Plotting particle data as a function of vy.')
        case 'z'
            vv = [0,0,1];
            ylab = '$v_z$ [km\,s$^{-1}$]';
            irf.log('w','Plotting particle data as a function of vz.')
        case 't'
            error('Our posturings, our imagined self-importance, the delusion that we have some privileged position in the Universe, are challenged by this point of pale light.')
        otherwise
            error('The Earth is the only world known so far to harbor life. There is nowhere else, at least in the near future, to which our species could migrate.')
    end
elseif isnumeric(yd) && length(yd)==3
    vv = yd/norm(yd); % For good measure
    irf.log('w',['Plotting ion data along n = [',num2str(vv),'].'])
    ylab = '$v_{\mathrm{n}}$ [km\,s$^{-1}$]';
else
    error('Why do you come here, and whyhyhyhyhyhyhyyy do you hang around?')
end


%% Data handling
u = irf_units;

switch F.name(7)
    case 'i'
        disp('ions')
        M = u.mp;
    case 'e'
        disp('electrons')
        M = u.me;
    otherwise
        error('something wrong in the name')
end

F4d = double(F.data);
% Format of F4d is [t,E,phi,th]
nt = size(F4d,1);

emat = F.energy;
nEn = size(emat,2);
nV = 2*nEn; % Number of velocity grid points


% Grid velocity
% vg = linspace(-max(vmat(first_parity+2,:)),max(vmat(first_parity+2,:)),nV);
% vg = linspace(-2000,2000,nV);
vmat = sqrt(2*emat*u.e/M)*1e-3;
vg = [-fliplr(vmat(1,:)),vmat(1,:)];

f = [];
f.t = F.time.epochUnix;
f.p = zeros(nt,nV);
f.f_label = 'velocity [km/s]';
f.f = vg;



TH = repmat(F.depend{3},nt,1,32,32);
TH = permute(TH,[1,3,4,2]);
PHI = repmat(F.depend{2},1,1,32,16);
PHI = permute(PHI,[1,3,2,4]);
VEL = repmat(vmat,1,1,32,16);

[VX,VY,VZ] = sph2cart((PHI-180)*pi/180,(90-TH)*pi/180,VEL);

VN = VX.*vv(1)+VY.*vv(2)+VZ.*vv(3);

% 4D psd matrix compensated for geometric factor
F4d_comp = F4d.*sind(TH);

for m = 1:nt
    % To 3D
    vn = squeeze(VN(m,:,:,:));
    F3d = squeeze(F4d_comp(m,:,:,:));
    idv = anjo.fci(vn,vg,'nan');
    for n = 1:nV
        f.p(m,n) = nanmean(F3d(idv==n));
    end
end


%% Plotting
f.p(f.p==0) = NaN;
f.p = f.p*1e30;
irf_spectrogram(AX,f);
irf_timeaxis(AX)

anjo.label(AX,ylab)

if nargout == 1
    out = f;
end

end

