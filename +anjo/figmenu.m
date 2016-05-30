function [varargout] = figmenu(f)
%ANJO.FIGMENU Helpful menu items.
%
%   ANJO.FIGMENU(f) Creates an option "anjo" in the irf figure menu.
%
%   mh = ANJO.FIGMENU Also returns handle to the uimenu.

% TODO: Change to recursive syntax for security.

%% Get the IRF menu handle
if(nargin == 0)
    f = gcf;
end

irf.log('w',['Creating dropdown menu for figure ',num2str(f.Number)])

% Initiate IRF figmenu
irf_figmenu

% Get the menu handle
mirf = findall(f.Children,'Type','uimenu','Label','&irf');

%% Create menu items
mh = uimenu(mirf,'Label','&anjo');
mh.Separator = 'on';
menuLabels = {'Fix axes position','Restore x-axis','Box'};

nl = length(menuLabels);
m2h = gobjects(1,nl);

for i = 1:nl
    if strcmp(menuLabels{i},'Restore x-axis')
        m2h(i) = uimenu(mh,'Label',menuLabels{i},'Accelerator','x');
    else
        m2h(i) = uimenu(mh,'Label',menuLabels{i});
    end
end


%% Create individual submenus and commands

% 1 - fix x-label
m2h(1).Callback = 'anjo.fix_x_label';


% 2 - remove time axis
cmd3 = ['tempFIG=gcf;',...
    'tempAXar = findall(tempFIG.Children,''Type'',''Axes'');',...
    'tempAX = tempAXar(1);',...
    'tempAX.XLabel.String = tempAX.UserData.XLabel.String;',...
    'tempAX.XTickLabelMode = ''auto'';',...
    'tempAX.XTickMode = ''auto'';',...
    'clear tempAX tempAXar tempFIG'];
m2h(2).Callback = cmd3;

% 3 - Box
cmd4 = ['tempFIG=gcf;',...
    'tempAXar = findall(tempFIG.Children,''Type'',''Axes'');',...
    'anjo.box(tempAXar);',...
    'clear tempAXar tempFIG'];
m2h(3).Callback = cmd4;


if(nargout==1)
    varargout{1} = mh;
end

end


