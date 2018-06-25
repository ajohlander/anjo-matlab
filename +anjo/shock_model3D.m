function [xsh,ysh,zsh] = shock_model3D(varargin)
% Lets do 3D!


%% Input

[ax,args,nargs] = axescheck(varargin{:});
r = args{1};
args = args(2:end);
if isempty(ax); ax = gca; end

%% Check for flags

% Set default values
shModel = 'farris';
alpha0 = 3.5; % degrees
N = 5e3;
Nrot = 50;
cmode = 'thbn';
Bu = [];
xlim = [-50,30]; %todo
ylim = [-40,40]; %todo
efsh = 0;

have_options = nargs > 1;
while have_options
    switch(lower(args{1}))
        case 'shmodel'
            shModel = args{2};
        case 'alpha0'
            alpha0 = args{2};
        case 'n'
            N = args{2};
        case 'nrot'
            Nrot = args{2};
        case 'cmode'
            cmode = args{2};
        case 'bu'
            Bu = args{2};
        case 'efsh' % e foreshock
            efsh = args{2};
    end
    args = args(3:end);
    if isempty(args), break, end
end

% unit vector
bu = Bu/norm(Bu)

%% hgu
% first 2D
[xsh,ysh,x0,y0,alpha] = anjo.shock_model(r,shModel,alpha0,N);

% assume x0=y0=0
% unit vector pointing from earth to nose
ehat = [sqrt(1-tand(alpha)^2/(1+tand(alpha)^2)),-sqrt(tand(alpha)^2/(1+tand(alpha)^2)),0];


% % dbug
% plot(xsh,ysh,'k-'); hold on;
% plot(xsh(idmin),ysh(idmin),'r+')
% plot(0,0,'b*'); axis equal;



%% rotation

% see https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
th = linspace(0,pi,Nrot);

rrot = zeros(N,Nrot,3);
for ii = 1:N
    v = [xsh(ii),ysh(ii),0]; % fix here too
    for jj = 1:Nrot
        rrot(ii,jj,:) = cos(th(jj))*v+sin(th(jj))*cross(ehat,v)+...
            (1-cos(th(jj)))*dot(ehat,v)*ehat;
    end
end



%% Plot
hold(ax,'on')
hsf = surface(ax,rrot(:,:,1),rrot(:,:,2),rrot(:,:,3));
shading(ax,'flat')
axis(ax,'equal')
view(3)
hsf.CData = zeros(size(hsf.CData));

xlabel(ax,'$X_{GSE}$ [$R_E$]','interpreter','latex')
ylabel(ax,'$Y_{GSE}$ [$R_E$]','interpreter','latex')
zlabel(ax,'$Z_{GSE}$ [$R_E$]','interpreter','latex')

ax.FontSize = 14;
ax.Layer = 'top';
ax.LineWidth = 1.3;
grid(ax,'on');

ax.XLim = xlim; ax.YLim = ylim; ax.ZLim = ylim;

% draw earth
sphere(ax,20)

disp('tshirt')

%% Set color

nsh = get_sh_normal(rrot);

% cbar string
cbstr = '';

switch cmode
    case 'thbn' % shock angle
        if isempty(Bu)
            irf.log('w','no magnetic field provided')
        else
            cbstr = '$\theta_{Bn}$ [$^\circ$]';
            thBn = get_thBn(nsh,Bu,1);
            hsf.CData = thBn;
        end
    case 'nx'
        hsf.CData = nsh(:,:,1);
        cbstr = '$n_x';
    case 'ny'
        hsf.CData = nsh(:,:,2);
        cbstr = '$n_y$';
    case 'nz'
        hsf.CData = nsh(:,:,3);
        cbstr = '$n_z$';
end


hcb = colorbar(ax);
hcb.Label.Interpreter = 'latex';
hcb.Label.String = cbstr;
hcb.Label.FontSize = 14;
hcb.LineWidth = 1.3;


%% Make electron foreshock

if efsh
    % first get thbn with leq90=0
    thBn = get_thBn(nsh,Bu,0);
    
    refoot = get_efsh_foot(rrot,thBn);
    
    for ii = 1:Nrot
        if refoot(ii,1)~=0 && refoot(ii,2)~=0 && refoot(ii,3)~=0
            plot3(ax,refoot(ii,1),refoot(ii,2),refoot(ii,3),'r*','markersize',20)
            plot3(ax,refoot(ii,1)-[0,bu(1)]*1e3,refoot(ii,2)-[0,bu(2)]*1e3,refoot(ii,3)-[0,bu(3)]*1e3,'k')
        end
    end
    
end


%% hack


xsh = 1; ysh = 1; zsh = 1;

end


function nsh = get_sh_normal(rrot)
% foo

nsh = zeros(size(rrot));
N = size(rrot,1);
Nrot = size(rrot,2);

for ii = 2:N-1
    %disp([num2str(ii),'/',num2str(N-1)])
    for jj = 1:Nrot
        
        [th,~] = cart2pol(rrot(ii,jj,2),rrot(ii,jj,3));
        
        % fix when th is 0 or pi
        % also fix edges
        
        dx = rrot(ii+1,jj,1)-rrot(ii-1,jj,1);
        dy = rrot(ii+1,jj,2)-rrot(ii-1,jj,2);
        dz = rrot(ii+1,jj,3)-rrot(ii-1,jj,3);
        
        n1 = 1; % guess
        
        dth = pi/4; % interval
        if (th<dth && th>-dth) || (th>pi-dth || th<-pi+dth)
            %n2 = -n1*dx/dy; 
            %n2 = 100;
            %n3 = 0;
        % elseif 
            %n2 = -n1*dx/dy;
            %n2 = -100;
            %n3 = 0;
            
            n3 = -n1*dx/(dy/tan(th)+dz);
            n2 = -(n1*dx+n3*dz)/dy;
            
        else
            n2 = -n1*dx/(dz*tan(th)+dy);
            n3 = -(n1*dx+n2*dy)/dz;
        end
        
        % renormalize
        nsh(ii,jj,:) = [n1,n2,n3]/norm([n1,n2,n3]);
        
    end
end

% fix edges with hack
nsh(1,:,:) = nsh(2,:,:);
nsh(end,:,:) = nsh(end-1,:,:);


end


function thBn = get_thBn(nsh,Bu,leq90)

N = size(nsh,1);
Nrot = size(nsh,2);
thBn = zeros(size(nsh(:,:,1)));
for ii = 1:N
    for jj = 1:Nrot
        th = acosd(dot(squeeze(nsh(ii,jj,:)),Bu)/norm(Bu));
        if th<=90 && leq90
            thBn(ii,jj) = th;
        else
            thBn(ii,jj) = 180-th;
        end
        
    end
end

end


function refoot = get_efsh_foot(rrot,thBn)
Nrot = size(rrot,2);
refoot = zeros(Nrot,3);
for ii = 1:Nrot
    % find where cos(thbn) crosses zero -> thBn = 90
    id90 = cosd(thBn(1:end-1,ii)).*cosd(thBn(2:end,ii))<0;
    
    if ~isempty(find(id90, 1))
        try
            refoot(ii,:) = squeeze(rrot(id90,ii,:))';
        catch
            disp('dumb dumb dumb')
        end
    end
end
end


%% old and sad
%             %th = atan(rrot(ii,jj,3)/rrot(ii,jj,2));
%             [th,~] = cart2pol(rrot(ii,jj,2),rrot(ii,jj,3));
%
%             dx = rrot(ii+1,jj,1)-rrot(ii-1,jj,1);
%             dy = rrot(ii+1,jj,2)-rrot(ii-1,jj,2);
%             dz = rrot(ii+1,jj,3)-rrot(ii-1,jj,3);
%
% %             % Do it properly analytically
% %             n1 = 1; % guess
% %             n2 = -n1*dx/(dz/tan(th)+dy);
% %             n3 = -(n1*dx+n2*dy)/dz;
%
% %             % ugly ugly numerical way
% %             fun1 = @(n)n(1)*dx+n(2)*dy+n(3)*dz;
% %             fun2 = @(n)n(1)^2+n(2)^2+n(3)^2-1;
% %             fun3 = @(n)n(3)/n(2)-tan(th);
% %
% %             sfun = @(n)fun1(n)^2+fun2(n)^2+fun3(n)^2;
% %             % super slow probs
% %             n0 = fminsearch(sfun,squeeze(rrot(ii,jj,:))'/norm(squeeze(rrot(ii,jj,:))'));
% %
% %             if n0(1)<0
% %                 n0 = -n0;
% %             end
%
%             % new and exiting hybrid way
%             % first find just some normal vector
%             n1 = 1; n2 = 1;
%             n3 = -(n1*dx+n2*dy)/dz;
%             % normal not unit vector
%             n = [n1,n2,n3];
%             % unit vector
%             ehat = [dx,dy,dz]/norm([dx,dy,dz]);
%             % get azimuthal angle
%             [phi,~] = cart2pol(n2,n3);
%             % rodriguez roation
%             nrot = cos(th-phi)*n+sin(th-phi)*cross(ehat,n)+...
%             (1-cos(th-phi))*dot(ehat,n)*ehat;
%
%             % flip
%             if nrot(1)<0; nrot = -nrot; end
%             % renormalize and add to thing
%             nsh(ii,jj,:) = nrot/norm(nrot);
%
% %            nsh(ii,jj,:) = n0;
% %             nsh(ii,jj,:) = [n1,n2,n3]/norm([n1,n2,n3]);
%


