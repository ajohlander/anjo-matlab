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


switch yd
    case 'x'
        vv = [1,0,0];
        ylab = '$v_x$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vx.')
    case 'y'
        vv = [0,1,0];
        ylab = '$v_y$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vy.')
    case 'z'
        vv = [0,0,1];
        ylab = '$v_z$ [kms$^{-1}$]';
        irf.log('w','Plotting ion data as a function of vz.')
    case 't'
        error('Our posturings, our imagined self-importance, the delusion that we have some privileged position in the Universe, are challenged by this point of pale light.')
    otherwise
        if isnumeric(yd)
            vv = yd;
        else
            error('The Earth is the only world known so far to harbor life. There is nowhere else, at least in the near future, to which our species could migrate.')

        end
end


%% Data handling

F4d = double(F.data);
% Format of F4d is [t,E,phi,th]
nt = size(F4d,1);

[e0,e1,phi,th] = anjo.m.fpi_vals;
u = irf_units;

% Phi handling
if isfield(F.userData,'phi') && ~isempty(F.userData.phi)
    phi = double(F.userData.phi.data)-180; %remove this
else
    phi = repmat(phi,nt,1);
end

nTh = length(th);
nEn = length(e0);
nPhi = size(phi,2); % look out for bug here
    
emat = zeros(nt,32);
if first_parity == 0
    emat(1:2:end,:) = repmat(e0,floor(nt/2)+mod(nt,2),1);
    emat(2:2:end,:) = repmat(e1,floor(nt/2),1);
else
    emat(1:2:end,:) = repmat(e1,floor(nt/2)+mod(nt,2),1);
    emat(2:2:end,:) = repmat(e0,floor(nt/2),1);
end

v = sqrt(2.*emat.*u.e./u.mp)./1e3;

% Assumes n >= 3.
vf = linspace(-max(v(first_parity+2,:)),max(v(first_parity+2,:)),64);


f = [];
f.t = F.time.epochUnix;
f.p = zeros(nt,nEn*2);
f.f_label = 'velocity [km/s]';
f.f = vf;

for m = 1:2
    len = length(m:2:nt);
    vp = zeros(len,3);
    for i = 1:nTh
        for j = 1:nPhi
            for k = 1:nEn
                azi = phi(m:2:end,j)*pi/180;
                elev = repmat(th(i),len,1)*pi/180;
                r = v(m:2:end,k);
                
                [vp(:,1),vp(:,2),vp(:,3)] = sph2cart(azi,elev,r);
                
                % I'm sure this is a good operation!
                vproj = diag(repmat(vv,len,1)*vp');
                
                idv = anjo.fci(vproj,vf,'ext');
                
                f.p(m:2:end,idv) = f.p(m:2:end,idv)+repmat(F4d(m:2:end,k,j,i),1,len).*cosd(th(i));
            end
        end
    end
end
   
%% Plotting
f.p = f.p*1e30;
irf_spectrogram(AX,f);
irf_timeaxis(AX)

% hcb = colorbar(AX);
% anjo.label(hcb,'$\log{F}$ [s$^3$cm$^{-6}$]')

anjo.label(AX,ylab)

if nargout == 1
    out = f;
end

end

