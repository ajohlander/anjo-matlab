function [] = fpi_plot_sm(varargin)
%FPI_PLOT_SM Plot skymap
%   Detailed explanation goes here AX,f,t,idE,B

%% Input
ish = ishandle(varargin{1});
if ish
    AX = varargin{1};
else
    AX = fig;
end

F = varargin{1+ish};
t = varargin{2+ish};
idE = varargin{3+ish};

idt = anjo.fci(t.epochUnix,F.time.epochUnix,'ext');
T = F.time(idt);
irf.log('w',['Uses ion data from time: ',T.utc,'.'])

if nargin > 3+ish
    if isa(varargin{4+ish},'TSeries') || varargin{4+ish} ~= 0;
    binp = true;
    B = varargin{4+ish};
    b = B.resample(T).data;
    [Bpphi,Bpth,~] = cart2sph(b(1),b(2),b(3));
    [Bmphi,Bmth,~] = cart2sph(-b(1),-b(2),-b(3));
    
    if Bpphi<0
        Bpphi = 2*pi+Bpphi;
    end
    if Bmphi<0
        Bmphi = 2*pi+Bmphi;
    end
    Bpth = pi/2-Bpth;
    Bmth = pi/2-Bmth;
    else
        binp = false;
    end
else
    binp = false;
end

if nargin > 4+ish
    fluff = varargin{5+ish};
end


%% Plot
% [t,E,phi,th]

azi = F.userData.phi_inst(idt,:);
th = [5.6250000,16.875000,28.125000,39.375000,50.625000,61.875000,73.125000,84.375000,95.625000,106.87500,118.12500,129.37500,140.62500,151.87500,163.12500,174.37500];
etab = F.userData.emat(idt,:);
F3d = squeeze(F.data(idt,:,:,:));

if length(idE) == 1
    psd = squeeze((F3d(idE,:,:)));
else
    psd = squeeze(nanmean(F3d(idE,:,:)));
end
    
spec = [];
if isfield(AX.Parent.UserData,'t_start_epoch')
    t_start = AX.Parent.UserData.t_start_epoch;
else
    t_start = 0;
end
spec.t = azi+t_start;
spec.f = th;
spec.p = psd;
hold(AX,'off')
irf_spectrogram(AX,spec)
axis(AX,'equal')
AX.XTickMode = 'auto';
AX.XTickLabelMode = 'auto';


AX.XLim = [0,360];

AX.YLim = [0,180];

if fluff
    anjo.label(AX,'x','$\varphi$ [$^{\circ}$]')
    anjo.label(AX,'y','$\theta$ [$^{\circ}$]')
    
else
    AX.XLabel.String = '';
    AX.YLabel.String = '';
end
title(AX,[num2str(etab(idE(1))),'-',num2str(etab(idE(end))),' eV'])
colorbar(AX)

if binp
    hold(AX,'on')
    plot(AX,Bpphi*180/pi,Bpth*180/pi,'r.','MarkerSize',20);
    plot(AX,Bpphi*180/pi,Bpth*180/pi,'ro','MarkerSize',20);
    plot(AX,Bmphi*180/pi,Bmth*180/pi,'rx','MarkerSize',20);
    plot(AX,Bmphi*180/pi,Bmth*180/pi,'ro','MarkerSize',20);
    
end

%hpc = pcolor(azi,th,psd');
% shading flat
% axis equal



end
