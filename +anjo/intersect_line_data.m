function [xIntersect,yIntersect] = intersect_line_data(k,m,xData,yData)
%INTERSECT_LINE_DATA Summary of this function goes here
%   Detailed explanation goes here


len = length(xData);
lX = xData;
lY = k*lX+m;

yFlat = yData-lY;

interInd = find(yFlat(1:end-1).*yFlat(2:end)<=0,1);

%xIntersect = lX(interInd);


interInd 
len
%refined
if(interInd == len)
    kA = diff(yData(interInd-1:interInd))/diff(xData(interInd-1:interInd));
    mA = yData(interInd)-kA*xData(interInd);
    xIntersect = (m-mA)/(kA-k);
elseif(interInd == 1)
    
    kA = diff(yData(interInd:interInd+1))/diff(xData(interInd:interInd+1));
    mA = yData(interInd)-kA*xData(interInd);
    xIntersect = (m-mA)/(kA-k);
else
    
    kA = diff(yData(interInd:interInd+1))/diff(xData(interInd:interInd+1));
    mA = yData(interInd)-kA*xData(interInd);
    xIntersect = (m-mA)/(kA-k);
    
end
end