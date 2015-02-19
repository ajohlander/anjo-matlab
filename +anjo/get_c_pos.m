function [R] = get_c_pos(t)
%GET_C_POS Summary of this function goes here
%   Detailed explanation goes here

if length(t) == 1
    tint = [t-35,t+35];
    R = 0;
    
    R.R1 = local.c_read('sc_r_xyz_gse__C1_CP_AUX_POSGSE_1M',tint);
    R.R2 = local.c_read('sc_r_xyz_gse__C2_CP_AUX_POSGSE_1M',tint);
    R.R3 = local.c_read('sc_r_xyz_gse__C3_CP_AUX_POSGSE_1M',tint);
    R.R4 = local.c_read('sc_r_xyz_gse__C4_CP_AUX_POSGSE_1M',tint);
    
end
end

