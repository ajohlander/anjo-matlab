function [v] = fpi_get_vel(tint,part,id)
%FPI_GET_VEL Returns FPI velocity moments in GSE
%   Detailed explanation goes here


c_eval('vx_dbcs = mms.db_get_ts([''mms?_fpi_brst_l2_d'',part,''s-moms''],[''mms?_d'',part,''s_bulkx_dbcs_brst''],tint);',id);
c_eval('vy_dbcs = mms.db_get_ts([''mms?_fpi_brst_l2_d'',part,''s-moms''],[''mms?_d'',part,''s_bulky_dbcs_brst''],tint);',id);
c_eval('vz_dbcs = mms.db_get_ts([''mms?_fpi_brst_l2_d'',part,''s-moms''],[''mms?_d'',part,''s_bulkz_dbcs_brst''],tint);',id);

v_dbcs_ts = irf.ts_vec_xyz(vx_dbcs.time.ttns,[vx_dbcs.data vy_dbcs.data vz_dbcs.data]);

c_eval('defatt = mms.db_get_variable(''mms?_ancillary_defatt'',''zra'',tint);',id)
c_eval('defatt.zdec=mms.db_get_variable(''mms?_ancillary_defatt'',''zdec'',tint).zdec;',id)

v = mms_dsl2gse(v_dbcs_ts,defatt);


end

