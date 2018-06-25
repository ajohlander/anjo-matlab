function [sPDist,sPDistErr] = get_combined_pdist(tint,spec,id)
% maybe faster than mms.get_data
% times stamps may be off ~2*10^-7 s (probably not a problem)


% get the time every 10 seconds
time = irf.time_array(irf_time(tint(1).epochUnix+.1:10:tint(2).epochUnix-.1,'epoch>utc'));

filepath_and_filename = cell(size(time));

for j = 1:length(time)  
    try
        filepath_and_filename{j} = mms.get_filepath(['mms',num2str(id),'_fpi_brst_l2_d',spec,'s-dist'],time(j));
    end
end

% get unique files
try
    filepath_and_filename_unique = unique(filepath_and_filename);
catch
    sPDist = [];
    sPDistErr = [];
    return
end
    
PDistAr = cell(size(filepath_and_filename_unique));
PDistErrorAr = cell(size(filepath_and_filename_unique));

% number of time steps
nt = zeros(size(filepath_and_filename_unique));
for j = 1:length(filepath_and_filename_unique)
    [PDistAr{j},PDistErrorAr{j}] = mms.make_pdist(filepath_and_filename_unique{j});
    nt(j) = size(PDistAr{j}.data,1);
end
Nt = sum(nt);


% merge time, data, energy, phi, and theta
% assume energy, phi and theta is the same for error (only data differs)
pData = zeros(Nt,size(PDistAr{1}.data,2),size(PDistAr{1}.data,3),size(PDistAr{1}.data,4));
pErr = pData;
pTimeEpoch = zeros(Nt,1);
pEnergy = zeros(Nt,size(PDistAr{1}.data,2));
pPhi = zeros(Nt,size(PDistAr{1}.data,3));
esteptable = zeros(Nt,1);
% pTheta = zeros(Nt,size(PDistAr{1}.data,4));

% time index
idt = 1;
for j = 1:length(filepath_and_filename_unique)
    pData(idt:idt+nt(j)-1,:,:,:) = PDistAr{j}.data;
    pErr(idt:idt+nt(j)-1,:,:,:) = PDistErrorAr{j}.data;
    pEnergy(idt:idt+nt(j)-1,:) = PDistAr{j}.depend{1};
    pTimeEpoch(idt:idt+nt(j)-1,:) = PDistAr{j}.time.epochUnix;
    pPhi(idt:idt+nt(j)-1,:) = PDistAr{j}.depend{2};
    esteptable(idt:idt+nt(j)-1) = PDistAr{j}.ancillary.esteptable;
    idt = idt+nt(j);
end


sPDist = PDist(irf.time_array(irf_time(pTimeEpoch,'epoch>ttns')),pData,'skymap',pEnergy,pPhi,PDistAr{1}.depend{3});
sPDistErr = PDist(irf.time_array(irf_time(pTimeEpoch,'epoch>ttns')),pErr,'skymap',pEnergy,pPhi,PDistAr{1}.depend{3});

% do the thing
sPDist.species = PDistAr{j}.species;
% sPDist.ancillary = PDistAr{j}.ancillary;
sPDist.units = PDistAr{j}.units;
sPDist.siConversion = PDistAr{j}.siConversion;
sPDist.name = PDistAr{j}.name;

sPDistErr.species = PDistAr{j}.species;
sPDist.ancillary.energy0 = PDistAr{j}.ancillary.energy0;
sPDist.ancillary.energy1 = PDistAr{j}.ancillary.energy1;
sPDist.ancillary.esteptable = esteptable;
sPDistErr.units = PDistAr{j}.units;
sPDistErr.name = PDistAr{j}.name;

% should add version number





end