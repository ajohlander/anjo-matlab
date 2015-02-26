function [eField] = get_3d_e_field(tint,scInd)
%ANJO.GET_3D_E_FIELD Summary of this function goes here
%   AAAAAAAAAAAAAAAAAAAA TYPING!!!!!!!!

if(scInd == 1 || scInd == 2 || scInd == 3 || scInd == 4)
    dataStr = ['E_Vec_xyz_ISR2__C',num2str(scInd),'_CP_EFW_L2_E3D_INERT'];
    eField = local.c_read(dataStr,tint);
    
else
    eField = zeros(1,4);
    disp('Not a spacecraft!')
    return;
end

end
