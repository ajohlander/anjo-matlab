function [ionMat,t] = get_hia_data(tint,scInd,dataMode)
%ANJO.GET_HIA_DATA returns data from HIA in phase space density [s^3km^-6].
%   [ionMat,t] = ANJO.GET_HIA_DATA(tint,scInd,mode) returns data in
%   matrix ionMat and time vector t. tint is the time interval for the
%   data, scInd is the spacecraft number (1 or 3).
%
%   mode:
%       'default'   - returns full 4-D matrix.
%       '3d'        - like default but matrix N*16x8x31
%       'energy'    - integrates over polar angle
%       'polar'     - integrates over energy
%
%   See also: ANJO.GET_ONE_HIA_SPIN
%
%   ONLY WORKS FOR SUBSPIN DATA

if(scInd == 1 || scInd == 3)
    dataStr = ['3d_ions__C',num2str(scInd),'_CP_CIS-HIA_HS_MAG_IONS_PSD'];
else
    disp('NO HIA DATA');
    ionMat = zeros(8,16,31);
    return;
end

ion3d = local.c_read(dataStr,tint);
ionArray = double(ion3d{2});
tArray = double(ion3d{1});

th = anjo.get_hia_values('theta');

if(nargin == 3)
    if(nargin == 3 && strcmp(dataMode,'default'))
        % do nothing
        ionMat = ionArray;
        t = tArray;
        
    elseif(strcmp(dataMode,'energy'))
        % sum over polar angle
%         ionArray = squeeze(sum(ionArray,2));
        ionArray = hia_sum_over_pol(ionArray);
        tNum = size(ionArray,1);
        ionMat = zeros(tNum*16,31);
        t = zeros(1,tNum*16);
        
        for i = 1:tNum
            tInd = (i-1)*16+1;
            ionMat(tInd:tInd+15,:) = squeeze(ionArray(i,:,:));
            
            %recalculate tSpin everytime
            if(i == tNum)
                tSpin = mean(diff(tArray));
            else
                tSpin = tArray(i+1)-tArray(i);
            end
            t(tInd:tInd+15) = tArray(i)+linspace(0,tSpin*15/16,16);
        end
        
    elseif(strcmp(dataMode,'polar'))
        % sum over energy
        ionArray = squeeze(sum(ionArray,4));
        tNum = size(ionArray,1);
        ionMat = zeros(tNum*16,8);
        t = zeros(1,tNum*16);
        
        for i = 1:tNum
            tInd = (i-1)*16+1;
            ionMat(tInd:tInd+15,:) = squeeze(ionArray(i,:,:))';
            
            %recalculate tSpin everytime
            if(i == tNum)
                tSpin = mean(diff(tArray));
            else
                tSpin = tArray(i+1)-tArray(i);
            end
            t(tInd:tInd+15) = tArray(i)+linspace(0,tSpin*15/16,16);
        end
        
    elseif(strcmp(dataMode,'3d'))
        
        tNum = size(ionArray,1);
        ionMat = zeros(8,tNum*16,31);
        t = zeros(1,tNum*16);
        
        
        for i = 1:tNum
            tInd = (i-1)*16+1;
            ionMat(:,tInd:tInd+15,:) = squeeze(ionArray(i,:,:,:));
            
            %recalculate tSpin everytime
            if(i == tNum)
                tSpin = mean(diff(tArray));
            else
                tSpin = tArray(i+1)-tArray(i);
            end
            t(tInd:tInd+15) = tArray(i)+linspace(0,tSpin*15/16,16);
        end
        ionMat = permute(ionMat,[2,1,3]);
    end
end


end

