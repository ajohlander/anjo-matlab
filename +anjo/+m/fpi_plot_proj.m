function varargout = fpi_plot_proj(varargin)
%ANJO.M.FPI_PLOT_PROJ Plots projected ion data in velocity space.
%
%   ANJO.M.FPI_PLOT_PROJ(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_PLOT_PROJ(F,t,x1,x2) Plots particle data in velocity space
%   for sky map data F for time point t. If t is an interval, data is
%   averaged over interval. x1 and x2 are normal vector that defines the
%   projection plane. x1 and x2 *must* be perpendicular but not normalized.
%
%   F must have the structure returned by anjo.m.fpi_get_distr.
%
%   See also: ANJO.M.FPI_GET_DISTR.
%
%   TODO: Time averaging looks wierd; probably should only be 32 energy
%   bins. Electrons?


%% Input
ish = ishandle(varargin{1});
if ish
    AX = varargin{1};
else
    AX = anjo.afigure(1,[8,8]);
end

F = varargin{1+ish};
tint = varargin{2+ish};
x1 = varargin{3+ish};
x2 = varargin{4+ish};
show_cbar = 1;

if nargin >= 5+ish
    if ischar(varargin{5+ish}) && strcmpi(varargin{5+ish},'hidecolbar')
        show_cbar = 0;
    end
end

% string input
if ischar(x1)
    yl1 = x1;
    switch lower(x1)
        case 'x'
            x1 = [1,0,0];
        case 'y'
            x1 = [0,1,0];
        case 'z'
            x1 = [0,0,1];
    end
else
    yl1 = '1';
end
if ischar(x2)
    yl2 = x2;
    switch lower(x2)
        case 'x'
            x2 = [1,0,0];
        case 'y'
            x2 = [0,1,0];
        case 'z'
            x2 = [0,0,1];
    end
else
    yl2 = '2';
end

% normalize for good measure
x1 = x1/norm(x1);
x2 = x2/norm(x2);


%% Logs
% Give some output about whats happening

if cross(x1,x2) ~= 0
    error('x1 and x2 must be perpendicular')
else
    irf.log('w',['Plotting ion data as a function of '...
        ,num2str(round(x1,1)), ' and ', num2str(round(x2,1)),'.'])
end


%% Data handling
% Set parameters
F4d = double(F.data);
emat = F.userData.emat;
u = irf_units;
vmat = sqrt(2.*emat.*u.e./u.mp)./1e3;
phi = F.userData.phi;
th = F.userData.th;

nTh = size(th,2);
nPhi = size(phi,2);
nEn = size(emat,2);


% Time and velocity grid. Use correct energy table for single time input,
% use 64 energy bins for time interval input
if length(tint) == 2
    irf.log('w','Averages ion data over time, this usually turns out wierd.')
    %error('Time interval averaging is not yet implemented')
    idt = anjo.fci(tint.epochUnix,F.time.epochUnix,'ext');
    % number of time steps
    nt = length(F.time(idt(1):idt(2)));
    T = F.time(idt);
    % Velocity bin values
    vg = sort([vmat(idt(1),:),vmat(idt(1)+1,:)]);
else
    idt = anjo.fci(tint.epochUnix,F.time.epochUnix,'ext');
    T = F.time(idt);
    irf.log('w',['Uses ion data from time: ',T.utc,'.'])
    % number of time steps
    nt = 1;
    % Velocity bin values
    vg = vmat(idt,:);
end

% Number of velocity bins
nV = length(vg);

% Azimuthal angle bin values
phig = linspace(-pi,pi,nPhi);

[phiMesh,rMesh] = meshgrid(phig,vg); % Creates the mesh
[X,Y] = pol2cart(phiMesh-pi/nPhi,rMesh);    % Converts to cartesian

% Awesome 4D matricies ,[t,E,phi,th]
TH = repmat(th*pi/180,1,1,nEn,nPhi); % now [t,th,E,phi]
TH = permute(TH,[1,3,4,2]);
PHI = repmat(phi*pi/180,1,1,nEn,nTh); % now [t,phi,E,th]
PHI = permute(PHI,[1,3,2,4]);
VEL = repmat(vmat,1,1,nPhi,nTh); % now [t,E,phi,th], correct!

F4d_comp = F4d.*cos(TH);

[VX,VY,VZ] = sph2cart(PHI,TH,VEL);

V1 = VX.*x1(1)+VY.*x1(2)+VZ.*x1(3);
V2 = VX.*x2(1)+VY.*x2(2)+VZ.*x2(3);
[AZI,R] = cart2pol(V1,V2);

F3Mesh = zeros(nt,nEn,nPhi);
for m = idt
    F3d = squeeze(F4d_comp(m,:,:,:));
    %F3d = ones(32,32,16);
    r = squeeze(R(m,:,:,:));
    azi = squeeze(AZI(m,:,:,:));
    
    idv = anjo.fci(r,vg,'nan');
    idazi = anjo.fci(azi,phig,'nan');
    
    for n = 1:nV
        for k = 1:nPhi
            F3Mesh(m,n,k) = nanmean(F3d(idv==n & idazi==k));
        end
    end
end

% Average over time, if only one time step only squeeze
F2Mesh = squeeze(nanmean(F3Mesh,1));


%% Plotting
pcolor(AX,X,Y,log10(F2Mesh.*1e30));
shading(AX,'flat')

% Adds colorbar
if show_cbar
    hcb = colorbar(AX);
    anjo.label(hcb,'$\log{F}$ [s$^3$km$^{-6}$]') %[s$^3$km$^{-6}$]
end

anjo.label(AX,'x',['$v_{',yl1,'}$ [kms$^{-1}$]'])
anjo.label(AX,'y',['$v_{',yl2,'}$ [kms$^{-1}$]'])

axis(AX,'equal')

if nargout >= 1
    varargout{1} = F2Mesh;
end
if nargout == 2
    varargout{2} = T;
end

end