function [] = yzoom(varargin)
% only works on lines

% flag:
%       y - default, zoom in y
%       x - zoom in x
%       0 - use 0 as one of the limits in y

% for good measure
pause(0.05);


% if first input is axes handle (also true for input "1")
if ishandle(varargin{1}(1))
    ish = 1;
    ax = varargin{1};
else
    ish = 0;
    ax = gca;
end

% default values
flag = 'y';
fz = 0.05;

if nargin > ish
    % check if "next" input is flag or zoom parameter
    
    % if two extra inputs then flag must be first
    if nargin == ish+2
        flag = varargin{1+ish};
        fz = varargin{2+ish};
    elseif nargin == ish+1 % if only one extra it could be bolth
        if ischar(varargin{1+ish}) % flag
            flag = varargin{1+ish};
        elseif isnumeric(varargin{1+ish}) % fz
            fz = varargin{1+ish};
        end
    end
end



for k = 1:length(ax)
    % add more types if needed
    hc = findobj(ax(k).Children,'Type','Line','-not','Tag','irf_pl_mark');
    yl = [Inf,-Inf];
    xl = [Inf,-Inf];
    xdl = ax(k).XLim;
    
    for l = 1:length(hc)
        
        if ismember('y',flag)
            yd = hc(l).YData(hc(l).XData>xdl(1) & hc(l).XData<xdl(2));
            if min(yd)<yl(1)
                yl(1) = min(yd);
            end
            
            if max(yd)>yl(2)
                yl(2) = max(yd);
            end
            
            if yl(1)==Inf || yl(2)==-Inf
                yl = ax(k).YLim;
            end
        end
        
        if ismember('x',flag)
            xd = hc(l).XData;
            if min(xd)<xl(1)
                xl(1) = min(xd);
            end
            
            if max(xd)>xl(2)
                xl(2) = max(xd);
            end
            
            if xl(1)==Inf || xl(2)==-Inf
                xl = ax(k).XLim;
            end
        end

        
    end
    %ax(k).YLim = yl.*[1-sign(yl(1))*fz,1+sign(yl(2))*fz];
    
    if ismember('x',flag)
        irf_zoom(ax(k),'x',xl.*[1-sign(xl(1))*fz,1+sign(xl(2))*fz])
    end
    if ismember('y',flag) && ismember('0',flag)
        if prod(yl)<0
            irf.log('w','No')
            flag(flag=='0') = '';
        elseif yl(1)>=0
            irf_zoom(ax(k),'y',yl.*[0,1+sign(yl(2))*fz])
        elseif yl(1)<0
            irf_zoom(ax(k),'y',yl.*[1-sign(yl(1))*fz,0])
        end
    end
    if ismember('y',flag) && ~ismember('0',flag)
        irf_zoom(ax(k),'y',yl.*[1-sign(yl(1))*fz,1+sign(yl(2))*fz])
    end
end








