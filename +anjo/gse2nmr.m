function rPrime = gse2nmr(rSph,maxVar,n)
%GSE2NMR Awesome function
%   Something, something, wierd coordinate system
%   rSph = [rho, thetaN, phiN]

rCar = [rSph(1)*sind(rSph(2))*cosd(rSph(3)),...
    rSph(1)*sind(rSph(2))*sind(rSph(3)),...
    rSph(1)*cosd(rSph(2))];
z = maxVar;

zPrime = z-(z*n')*n;
zPrime = zPrime/sqrt(sum(zPrime.^2)); % Normalizing
yPrime = cross(n,zPrime);

rPrime = [-rCar*n', rCar*yPrime', rCar*zPrime'];

for i = 1:3
    if isnan(rPrime(i))
        disp('Something went wrong in gse2nmr!')
        return;
    end
end


return
        

end