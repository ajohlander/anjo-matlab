function [F,tData] = get_one_hia_spin(t,scInd,varargin)
%ANJO.GET_ONE_HIA_SPIN get ion data for one full spin of CIS-HIA.
%   psdMat = ANJO.GET_ONE_HIA_SPIN(t,scInd) returns ion data psdMat (matrix
%   of size 8x16x31) for spacecraft scInd = 1,3. The spin returned has
%   start time closest to the time t.
%   [psdMat,tData] = ANJO.GET_ONE_HIA_SPIN(t,scInd) also returns time vector
%   tData = [tStart,tStop].
%
%   See also: ANJO.GET_HIA_DATA
%
%   TODO: MAKE T START TIME.

%pDa = {'3d'};
pEn = {'full','half'};

enMode = anjo.incheck(varargin,pEn);

tint = [t-10,t+10];
[~,tArray] = anjo.get_hia_data(tint,scInd,enMode);
[F_3d,tvec] = anjo.get_hia_data(tint,scInd,enMode,'3d');

dataInd = anjo.find_closest_index(t,tArray);
tData = tArray(dataInd:dataInd+1);
tInd = find(tvec==tData(1));

% Chooses one spin
F = F_3d(:,tInd:tInd+15,:);

%F_3d = squeeze(F_4d(dataInd,:,:,:));

end