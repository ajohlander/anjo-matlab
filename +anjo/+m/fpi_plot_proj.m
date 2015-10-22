function out = fpi_plot_proj(varargin)
%ANJO.M.FPI_PLOT_PROJ Plots particle data in velocity space.
%
%   ANJO.M.FPI_PLOT_PROJ(AX,...) Plots in axes AX, initiates a figure if
%   omitted.
%
%   ANJO.M.FPI_PLOT_PROJ(F,t) Plots particle data in velocity space in XY
%   plane for TSeries object (struct) of sky map data for time point t. If
%   t is an interval data is averaged over interval.
%
%   ANJO.M.FPI_PLOT_PROJ(...,plane) Specify which plane to plot.
%
%   Planes: 'xy', 'yz', 'xz'.
%
%   Very unfinished. Only works for ions!
%
%   TODO: Implement planes other than 'xy'. Implement time interval.


%% Input

% Possible planes
pp = {'xy','yz','xz'};

ish = ishandle(varargin{1});
if ish
    AX = varargin{1};
else
    AX = anjo.afigure(1,[10,10]);
end

if nargin < 2+ish
    error('Not enough input parameters')
else
    tint = varargin{2+ish};
    f = varargin{1+ish};
    if nargin >= 3+ish
        plane = anjo.incheck(varargin(3+ish:end),pp);
    else
        plane = pp{1};
    end
end

% etab = 0:31;
% % Guess the elevation (or polar??) angle
% th = linspace(-90,90,16);
% %th = zeros(1,16);
% % Guess the azimuth
% phi0 = 165;
% phi = linspace(phi0,phi0+360,32);

% Guess all values in one line!!!
[etab,phi,th] = anjo.m.fpi_vals;
u = irf_units;
v = sqrt(2.*itab.*u.e./u.mp)./1e3;

nTh = length(th);
nPhi = length(phi);
nEn = length(itab);

%% Logs
% Give some output about whats happening
if length(tint) == 2
    irf.log('w','Averaging particle data over time interval given')
end
irf.log('w',['Plotting in the ',plane, '-plane'])



%% Data handling
if length(tint) == 2
    error('Time interval averaging is not yet implemented')
    %idstart = anjo.fci(tint(1).epoch,f.time.data);
    %...
else
    idt = anjo.fci(tint.epochUnix,f.time.epochUnix,'ext');
    %idt = find(tint.epoch<f.time.epoch,1);
    T = f.time(idt);
    f3d = squeeze(f.data(idt,:,:,:));
end

% Format of F3d is assumed to be [E,phi,th]
switch plane
    case 'xy'
        % 2D matrix to be filled.
        f2d = zeros(nPhi,nEn);
        
        % Rebins data
        for i = 1:nTh
            % ft is a 2D thcut-out of 3D distribution for one theta angle
            % [phi,E]
            ft = squeeze(f3d(:,:,i))';
            % new velocity table in xy-plane
            vt = v*cosd(th(i));
            % new indicies for the data
            idv = anjo.fci(vt,v,'ext');
            
            % loops through phi and energy
            for j = 1:nPhi
                for k = 1:nEn
                    % adds the data to the f2d matrix. cos(th) is a geometric
                    % factor.
                    f2d(j,idv(k)) = f2d(j,idv(k))+ft(j,k)*cosd(th(i)); %CHECK INDICIES!!
                end
            end
        end
        
        % Add one row of zeros, no new data
        f2dex = zeros(size(f2d)+[1,0]);
        f2dex(1:end-1,:) = f2d;
        
        
        nPhi = length(phi);
        % Adds phiP(17) = phi(1). The term 11.25 degres is to rotate the circle.
        phiP = interp1([phi,phi(1)],linspace(1,33,nPhi+1))-360/64;
        phiRad = phiP*pi/180;
        
        [PHI,R] = meshgrid(phiRad,v); % Creates the mesh
        [X,Y] = pol2cart(PHI,R);    % Converts to cartesian
        
    case 'xz'
        
         % 2D matrix to be filled.
        f2d = zeros(nTh*2,nEn);
        
        % Rebins data
        for j = 1:nPhi
            % ft is a 2D thcut-out of 3D distribution for one phi angle [th,E]
            ft = squeeze(f3d(:,j,:))';
            % Normal vector of the plane
            normvec = [0,1,0];
            
            
            for i = 1:nTh
                for k = 1:nEn
                    % Get angle between velocity vector and normal vector
                    [X,Y,Z] = sph2cart(phi(j)*pi/180,th(i)*pi/180,1); % vn in cartesian
                    nu = acosd(dot(normvec,[X,Y,Z]));
                    
                    %velocity projected on the plane
                    vt = v(k)*sind(nu);
                    idv = anjo.fci(vt,v,'ext');
                    % adds the data to the f2d matrix. cos(th) is a geometric
                    % factor.
                    if X(1)>=0
                        f2d(i,idv) = f2d(i,idv)+ft(i,k)*cosd(th(i));
                    else
                        f2d(33-i,idv) = f2d(33-i,idv)+ft(i,k)*cosd(th(i));
                    end
                    
                    
                end
            end
        end
       
        % Add one row of zeros, no new data
        f2dex = zeros(size(f2d)+[1,0]);
        f2dex(1:end-1,:) = f2d;
        
        thex = [th,th+180];
        thP = interp1([thex,thex(1)],linspace(1,33,33))-360/64;
        thRad = thP*pi/180;
        
        [TH,R] = meshgrid(thRad,v); % Creates the mesh
        [X,Y] = pol2cart(TH,R);    % Converts to cartesian
        
        
    otherwise
        error(['Plane ', plane, ' is not yet implemented'])
end

%% Plotting
pcolor(AX,X,Y,log10(f2dex'));
shading(AX,'flat')

% Adds colorbar
hcb = colorbar(AX);
anjo.label(hcb,'$\log{F}$ [s$^3$cm$^{-6}$]') %[s$^3$km$^{-6}$]

% Reverses the direction of the x-axis. The Sun is to the left!
AX.XDir = 'reverse';

anjo.label(AX,'x',['$v_{',plane(1),'}$ [kms$^{-1}$]'])
anjo.label(AX,'y',['$v_{',plane(2),'}$ [kms$^{-1}$]'])

axis(AX,'equal')

if nargout == 1
    out = T;
end

end