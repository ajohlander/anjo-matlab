function [f] = fpi_get_distr(type,tint,id,dataType,dataMode)
%ANJO.FPI_GET_DISTR Hacky way to get burst distribution function.
%   Will be deleted when there is a better alternative

if nargin < 4
    dataType = 'dist';
end

if nargin < 5
    dataMode = 'brst';
end

if length(id)>1
    error('no')
end

u = irf_units;


switch lower(type(1))
    case 'i'
        irf.log('w',['Reading FPI ion burst data from MMS',num2str(id),'.'])
        c_eval('f = mms.db_get_ts([''mms?_fpi_'',dataMode,''_l2_dis-dist''],[''mms?_dis_'',dataType,''_brst''],tint);',id);
        c_eval('phi = mms.db_get_ts([''mms?_fpi_'',dataMode,''_l2_dis-dist''],[''mms?_dis_phi_'',dataMode],tint);',id);
        c_eval('parity = mms.db_get_ts([''mms?_fpi_'',dataMode,''_l2_dis-dist''],[''mms?_dis_steptable_parity_'',dataMode],tint);',id);
        % set mass
        m = u.mp;
    case 'e'
        
        irf.log('w',['Reading FPI electron burst data from MMS',num2str(id),'.'])
        c_eval('f = mms.db_get_ts(''mms?_fpi_brst_l2_des-dist'',[''mms?_des_brstSkyMap_'',dataType],tint);',id);
        c_eval('phi = mms.db_get_ts(''mms?_fpi_brst_l2_des-dist'',''mms?_des_brstSkyMap_phi'',tint);',id);
        c_eval('parity = mms.db_get_ts(''mms?_fpi_brst_l2_des-dist'',''mms?_des_stepTable_parity'',tint);',id);
        % set mass
        m = u.me;
end

if isempty(f)
    irf.log('w','No burst particle data available')
else
    % Check if two or more cdfs are read.
    if size(f,2) > 1
        vers = zeros(1,length(f));
        for i = 1:length(f)
            vers(i) = get_fpi_version(f{i});
        end
        % Use file with newest version
        [~,file_id] = max(vers);
        f = f{file_id};
        if size(phi,2) > 1
            phi = phi{file_id};
        end
        if size(parity,2) > 1
            parity = parity{file_id};
        end
    end
    
    [e0,e1,phiTab,thTab] = anjo.m.fpi_vals;
    nt = length(f.time);
    emat = zeros(nt,32);
    id0 = find(parity.data==0);
    id1 = find(parity.data==1);
    
    emat(id0,:) = repmat(e0,length(id0),1);
    emat(id1,:) = repmat(e1,length(id1),1);
    
    vmat = sqrt(2.*emat.*u.e./m)./1e3;
    
    f.userData.parity = parity;
    f.userData.emat = emat;
    f.userData.vmat = vmat;
    
    if isempty(phi)
        irf.log('w','Phi angle not read from cdf, approximate value used')
        f.userData.phi = repmat(phiTab,nt,1);
    else
        f.userData.phi = double(phi.data)-180;
    end
    
    f.userData.th = repmat(thTab,nt,1);

    f = construct_4d_mat(f);
end
end

function vers = get_fpi_version(F)
    pattern = 'v[0-9].[0-9].[0-9]';
    str = F.userData.GlobalAttributes.Logical_file_id{1};
    [vid1,vid2] = regexp(str,pattern);
    vstr = str(vid1+1:vid2);
    
    vers = 0;
    for i = 1:3
        vers = vers+str2double(vstr(2*i-1))*10^(3-i);
    end

end


function F = construct_4d_mat(F)

    th = F.userData.th;
    phi = F.userData.phi;
    vmat = F.userData.vmat;
    
    nTh = size(th,2);
    nEn = size(vmat,2);
    nPhi = size(phi,2);
    
    % Awesome 4D matricies ,[t,E,phi,th]
    TH = repmat(th*pi/180,1,1,nEn,nPhi); % now [t,th,E,phi]
    TH = permute(TH,[1,3,4,2]);
    PHI = repmat(phi*pi/180,1,1,nEn,nTh); % now [t,phi,E,th]
    PHI = permute(PHI,[1,3,2,4]);
    VEL = repmat(vmat,1,1,nPhi,nTh); % now [t,E,phi,th], correct!

    F.userData.TH = TH;
    F.userData.PHI = PHI;
    F.userData.VEL = VEL;

end

