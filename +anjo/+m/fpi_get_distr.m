function [f] = fpi_get_distr(type,tint,id)
%ANJO.FPI_GET_DISTR Hacky way to get busrt distribution function.
%   Will be deleted when there is a better alternative

if length(id)>1
    error('no')
end



switch lower(type(1))
    case 'i' 
        irf.log('w',['Reading FPI ion burst data from MMS',num2str(id),'.'])
        c_eval('f = mms.db_get_ts(''mms?_fpi_brst_l1b_dis-dist'',''mms?_dis_brstSkyMap_dist'',tint);',id);
        c_eval('phi = mms.db_get_ts(''mms?_fpi_brst_l1b_dis-dist'',''mms?_dis_brstSkyMap_phi'',tint);',id);
        c_eval('parity = mms.db_get_ts(''mms?_fpi_brst_l1b_dis-dist'',''mms?_dis_stepTable_parity'',tint);',id);
    case 'e'
        error('no')
end

[e0,e1,phiTab,thTab] = anjo.m.fpi_vals;

nt = length(f.time);
emat = zeros(nt,32);
id0 = find(parity.data==0);
id1 = find(parity.data==1);

emat(id0,:) = repmat(e0,length(id0),1);
emat(id1,:) = repmat(e1,length(id1),1);

f.userData.parity = parity;
f.userData.emat = emat;

if isempty(phi)
    irf.log('w','Phi angle not read from cdf, approximate value used')
    f.userData.phi = repmat(phiTab,nt,1);
else
    f.userData.phi = double(phi.data)-180;
end

f.userData.th = repmat(thTab,nt,1);


end

