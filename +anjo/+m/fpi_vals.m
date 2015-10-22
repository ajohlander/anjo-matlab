function [x1,x2,x3] = fpi_vals()
%ANJO.M.FPI_VALS Returns guessed values for FPI
%   
%   Detailed explanation goes here
%   [etab,phi,th] = ANJO.M.FPI_VALS
%


% returns an additional row vector, centers, indicating the location 
% of each bin center on the x-axis.
[~,th] = hist([-90,90],16);
[~,phi] = hist([-180,180],32);

% For ions energy is from 10 eV to 30 keV. Same for electrons?
% Lin -> Log. Not sure its good.
[~,xi] = hist([log10(10),log10(30e3)],32);

etab = 10.^xi;

% Out
if nargout == 0 % Print values
%     disp(['etab = ', num2str(etab)])
%     disp(['phi = ', num2str(phi)])
%     disp(['th = ', num2str(th)])

    A = [(1:32)',etab',phi',[th,NaN(1,16)]'];
    disp(['                    ','etab        ','phi          ','th           '])
    disp(round(A))
else
    x1 = etab;
    x2 = phi;
    x3 = th;
end



end

