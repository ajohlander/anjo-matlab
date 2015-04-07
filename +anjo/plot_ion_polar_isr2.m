function [h,hc] = plot_ion_polar_isr2(AX,psdMat,showColorbar)
%ANJO.PLOT_ION_POLAR_ISR2 plot CIS-HIA data in velocity space.
%   ANJO.PLOT_ION_POLAR_ISR2(psdMat,fn) plots ion data stored in psdMat (matrix
%   of size 8x16x31) in a figure (or axis?) handle fn. The function assumes
%   that all ions are protons.
%   hsf = ANJO.PLOT_ION_POLAR_ISR2(psdMat,fn) returns axis handle hsf for the surf
%   plot.
%
% NB. only for XY-plane so far 

mp = 1.67262178e-27; %proton mass

phi = [134.5830,112.0830,89.5830,67.0830,44.5830,22.0830,-0.4170,...
    -22.9170,-45.4170,-67.9170,-90.4170,-112.9170,-135.4170,-157.9170,...
    179.5830,157.0830]+11.25; %azimuthal angle from cis data


%azimuthal angle for plot
nPhi = 16;
phiP = interp1([phi,phi(1)],linspace(1,17,nPhi+1));
%phiP = phiP(1:nPhi);

theta = linspace(180-11.25,11.25,8); %Polar angle

psdSize = size(psdMat);
enRange = psdSize(3); % How many energy bins that are included.
length(phiP)
% phiRad = zeros(1,nPhi+1); %azimutal angle
% phiRad(1:nPhi) = (phiP(1:nPhi)+11.25)*pi/180; %radians
phiRad = phiP*pi/180;
% +11.25 because surf hadles borders, not centers

%phiRad(nPhi+1) = phiRad(1); %to close the circle

phiP = phiP(1:nPhi);
length(phiP)



% Energy table for CIS HIA, could also be imported.
eTab = 1e4*[2.8898330   2.1728221   1.6337120   1.2283630...
    0.9235880   0.6944320   0.5221330   0.3925840...
    0.2951780   0.2219400   0.1668730   0.1254690...
    0.0943390   0.0709320   0.0533320   0.0401000...
    0.0301500   0.0226700   0.0170450   0.0128160...
    0.0096360   0.0072450   0.0054480   0.0040960...
    0.0030800   0.0023160   0.0017410   0.0013090...
    0.0009840   0.0007400   0.0005560];

energy = eTab(32-enRange:31);
%Energy --> velocity
velocity = sqrt(2*energy*1.602e-19/mp)/1000;

n = enRange+2;
%vVec = linspace(0,max(velocity),n);
vVec = [15,20,fliplr(velocity)];


[PHI,R] = meshgrid(phiRad,vVec); %creates the mesh
[X,Y] = pol2cart(PHI,R);    %Converts to cartesian




psdXY = zeros(n,nPhi+1); % matrix with phase space density

% Fills it with CIS data. Integrated over theta.
% Project to XY-plane

%psdXY(:,1:16) = squeeze(sum(psdMat))'; 
%psdXY(:,1:16) = squeeze(psdMat(4,:,:))';



% XY plane
for i = 1:8
    for j = 1:16
        for k = 1:enRange
            velXY = velocity(k)*sind(theta(i));
            velInd = anjo.find_closest_index(velXY,vVec);
            psdXY(velInd,j) = psdXY(velInd,j)+psdMat(i,j,k);
        end
    end
end


%increasing phi
% phiFlip = fliplr(phi);
% phiInc = [phiFlip(3:end),phiFlip(1:2)];
%phiInc = sort(phiP);
            

% vx-sqrt(vy^2+vz^2) plane
% for i = 1:8
%     for j = 1:16
%         for k = 1:enRange
%             velXYZ = anjo.sph2car([velocity(k),theta(i),phi(j)]);
%             vX = velXYZ(1); vY = velXYZ(2); vZ = velXYZ(3);
%             vYZ = sqrt(vY^2+vZ^2);
%             phiPrime = atand(vYZ/vX);
%             
%             % 2
%             if(vX>0 && vYZ<0)
%                 phiPrime = 360 + phiPrime;
%             elseif(vX<0 && vYZ>0) %3
%                 phiPrime = 180 + phiPrime;
%             elseif(vX<0 && vYZ<0) %4
%                 phiPrime = 180 + phiPrime;
%             end
%             
%             
%             phiIncInd = anjo.findClosestIndex(phiPrime,phiInc);
%             phiInd = find(phiInc(phiIncInd) == phiP);
%             velInd = anjo.findClosestIndex(velocity(k),vVec);
%             psdXY(velInd,phiInd) = psdXY(velInd,phiInd)+psdMat(i,j,k);
%         end
%     end
% end



psdXY(:,nPhi) = psdXY(:,1)*1;
%psdXY(:,17) = (psdXY(:,1)+psdXY(:,16))/2; % this is not ideal
psdXY(psdXY==0) = min(min(psdXY(psdXY ~= 0))); % removes 0 values



logpsdXY = log10(psdXY); %logarithm
%logpsdXY = ones(25,17);
%logpsdXY(15,8) = 200;

% Plot everything


h = surf(AX,X,Y,logpsdXY);%,'EdgeColor', 'none');
h.EdgeColor = 'none';
%shading flat 



%ylabel(hc,'log_{10}dEF [Kev cm^{-2} s^{-1} sr^{-1} Kev^{-1}]')
%caxis([4 8]) % If needed
% 

velLim = 700;
ax = get(h,'parent');
% get(ax,'XLim')
% set(fn,'XLim',[-velLim, velLim])
% get(ax,'XLim')
%irf_zoom(fn,'x',[-velLim, velLim]);

axes(ax);
axis equal;

hc = colorbar('peer',ax);
anjo.label(hc,'$\log{F}$ [s$^3$km$^{-6}$]')
if showColorbar
    set(hc,'Visible','on');
        yL = AX.YLabel;
    yL.Visible = 'off';
else
    set(hc,'Visible','off');

end
xlim(ax,[-velLim, velLim])
ylim(ax,[-velLim, velLim])

grid off
view(ax,2)

anjo.label(ax,'x','$v_{x}$   [kms$^{-1}$]')
anjo.label(ax,'y','$v_{y}$   [kms$^{-1}$]')


end
