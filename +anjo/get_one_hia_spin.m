function [psdMat,tData] = get_one_hia_spin(t,scInd,mode)
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


if(nargin == 2)
    mode = 'default';
end

tint = [t-10,t+10];
[psdArray,tArray] = anjo.get_hia_data(tint,scInd,mode);

dataInd = anjo.find_closest_index(t,tArray);
tData = tArray(dataInd:dataInd+1);

psdMat = squeeze(psdArray(dataInd,:,:,:));

end