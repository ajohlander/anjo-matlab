function [f] = progress_pie(i,n,f)
%PROGRESS_PIE pie chart showing progress of a calculation
%   f = ANJO.PROGRESS_PIE(i,n) shows the progress inside a loop where i is the
%   current index and n is the total number of iterations. Returns figure
%   handle f.
%   ANJO.PROGRESS_PIE(i,n,f) shows progress in the figure f.
%
%   Usage: 
%       hWait = anjo.progress_pie(0,n);
%       for i = 1:n
%           anjo.progress_pie(i,n,hWait)
%           ...
%       end
%       close(hWait)


nSlice = 20;

if(round(i/n*nSlice)~=round((i-1)/n*nSlice) || nargin==2)
    
    if(nargin==2)
       
        
        set(0, 'Units', 'points');
        screenSize = get(0,'ScreenSize');
        pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
        width = 360 * pointsPerPixel;
        height = 360 * pointsPerPixel;
        pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
        
        
        
        f = figure(...
            'Units', 'points', ...
            'BusyAction', 'queue', ...
            'WindowStyle', 'normal', ...
            'Position', pos, ...
            'Resize','off', ...
            'CreateFcn','', ...
            'NumberTitle','off', ...
            'IntegerHandle','off', ...
            'MenuBar', 'none', ...
            'Tag','progpie',...
            'Interruptible', 'off', ...
            'DockControls', 'off', ...
            'Visible','on',...
            'Color','White');
        
        h = axes('Parent', f,'Tag','progpie');
        
        draw_pie(i,n,nSlice,h);
        print_text(i,n);

    elseif(nargin == 3)
        set(f,'Visible','on');
        h = axes('Parent', f);
        draw_pie(i,n,nSlice,h);
        set(get(h,'Title'),'String','')

        print_text(i,n);
        
    end
end

end

function [] = draw_pie(i,n,nSlice,h)

x = ones(1,nSlice);
hp = pie(h,x);
set(hp(2:2:end),'Visible','off'); % Hide labels
q = round(i/n*nSlice);

c = [0.5,0,0];
set(hp(1:2:end),'facecolor',c,'EdgeColor','none');
set(hp(1:2:(nSlice-q-1)*2),'Visible','off');

end



function [h] = print_text(i,n)
% 
prcent = floor(i/n*100);
progText = ['Progress: ',num2str(prcent),'%'];
disp(progText)

end

