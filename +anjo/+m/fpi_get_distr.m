function [f1,f2,f3,f4] = fpi_get_distr(type,tint,id)
%ANJO.FPI_GET_DISTR Hacky way to get busrt distribution function.
%   Will be deleted when there is a better alternative

switch lower(type(1))
    case 'i'
        
        c_eval('f? = mms.db_get_ts(''mms?_fpi_brst_l1b_dis-dist'',''mms?_dis_brstSkyMap_dist'',tint);',id);
        c_eval('phi? = mms.db_get_ts(''mms?_fpi_brst_l1b_dis-dist'',''mms?_dis_brstSkyMap_phi'',tint);',id);
    case 'e'
        error('no')
end

c_eval('f?.userData.phi = phi?;',id)



end

