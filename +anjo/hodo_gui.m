function [out] = hodo_gui(B,scInd)
%ANJO.HODO_GUI GUI for creating hodograms.
%
%   ANJO.HODO_GUI(B,scInd) Opens a plot with magnetic field B. Click start and
%   stop time for a hodogram. Quit by closing the GUI window.
%   
%   See also: ANJO.HODO

[h,~] = anjo.afigure(1,[15,8]);

anjo.plot_3d_b_field(h,B);
hMark = gobjects(1);

% Large number of hodograms
hHodo = gobjects(3,100);
nHodo = 1;

while true
    % Click start and stop time or vice versa
    try
    tint = click_time(h);
    catch
        irf.log('w','Closing hodo_gui, hodograms are left open.');
        if(nargout == 1)
            out = hHodo(nHodo);
        end
        return
    end
    % Get B in time interval chosen
    [Bcut,tlim] = cut_b(B,tint);
    
    % Marks time interval chosen
    delete(hMark)
    hMark = irf_pl_mark(h,tlim);
    
    % Plots hodogram
    hHodo(:,nHodo) = anjo.hodo(Bcut,scInd);
    nHodo = nHodo+1;
    
    % Hack to make loop work. Why does Matlab do this?
    pause(0.5);
end

end

function tint = click_time(AX)
axes(AX)
[tint,~] = ginput(2);

if(diff(tint)<0) % Should be increasing
    tint = fliplr(tint);
end
end

function [Bcut,tlim] = cut_b(B,tint)
t = B(:,1)-B(1,1);

ind = [anjo.find_closest_index(tint(1),t),...
    anjo.find_closest_index(tint(2),t)];

Bcut = B(ind(1):ind(2),:);
tlim = B(ind,1)';
end
