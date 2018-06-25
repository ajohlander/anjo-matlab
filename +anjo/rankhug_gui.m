function [out] = rankhug_gui(inp)
%RANKHUG_GUI Summary of this function goes here
%   Detailed explanation goes here

if nargin == 0
    ud = [];
    ud = def_outputs(ud);
    ud = init_gui(ud);
    anjo.rankhug_gui('plot');
end

if nargin == 1
    switch inp
        case 'plot'
            % only 'plot' now
            ud = get(gcf,'userdata');
            ud = set_par(ud);
            disp('Plotting...')
            tic
            ud = plot_rankhug(ud);
            toc
            set(gcf,'userdata',ud);
    end
end
if nargout == 1
    out = ud;
end

end


function ud = def_outputs(ud)

% list in pop-up menus
ud.out.names = {'nd/nu','Bd/Bu','Btd/Btu','thd','thd-th','Mdf','betad','Vd','Vdn','Vdt','MdI','th_dVn'};
ud.out.labels = {'$n_d/n_u$','$B_d/B_u$','$B_{td}/B_{tu}$','$\theta_{d,Bn}$','$\theta_{d,Bn}-\theta_{Bn}$','$M_{df}$','$\beta_d$','$V_d/V_{dA}$','$V_{dn}/V_{dA}$','$V_{dt}/V_{dA}$','MdI','$\theta_{d,Vn}$'};

end


function ud = init_gui(ud)
% init figure
[ud.ax,ud.fig] = anjo.afigure(1,[14,10]);
ud.ax.Position = [0.12,0.2,0.52,.7];


%% input panel
% panel
ud.ph1.panel = uipanel('Units', 'normalized',...
    'position',[0.69 0.62 0.29 0.37],...
    'fontsize',14,...
    'Title','Input');

% x text
ud.ph1.tx = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.05 0.8 0.3 0.15],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','X: ');
% x pop-up menu
ud.ph1.px = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.3 0.8 0.65 0.15],...
    'fontsize',14,...
    'string',{'th','Mf','beta'},...
    'Value',1);

% y text
ud.ph1.ty = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.05 0.65 0.3 0.15],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Y: ');
% y pop-up menu
ud.ph1.py = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.3 0.65 0.65 0.15],...
    'fontsize',14,...
    'string',{'th','Mf','beta'},...
    'Value',2);

% th text
ud.ph1.tth = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.05 0.45 0.3 0.15],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','th: ');
% th text box
ud.ph1.bth = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.3 0.45 0.65 0.15],...
    'fontsize',12,...
    'string','45');

% Mf text
ud.ph1.tmf = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.05 0.25 0.3 0.15],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Mf: ');
% Mf text box
ud.ph1.bmf = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.3 0.25 0.65 0.15],...
    'fontsize',12,...
    'string','3');

% beta text
ud.ph1.tb = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.05 0.05 0.3 0.15],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','beta: ');
%  beta text box
ud.ph1.bb = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph1.panel,...
    'position',[0.3 0.05 0.65 0.15],...
    'fontsize',12,...
    'string','0');

%% interval panel
% panel
ud.ph2.panel = uipanel('Units', 'normalized',...
    'position',[0.69 0.4 0.29 0.22],...
    'fontsize',14,...
    'Title','Intervals');

% th text
ud.ph2.tth = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.05 0.8 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','th: ');
%  th1 text box
ud.ph2.bth1 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.3 0.8 0.3 0.2],...
    'fontsize',12,...
    'string','1');
%  th2 text box
ud.ph2.bth2 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.65 0.8 0.3 0.2],...
    'fontsize',12,...
    'string','90');


% Mf text
ud.ph2.tmf = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.05 0.45 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Mf: ');
%  Mf1 text box
ud.ph2.bmf1 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.3 0.45 0.3 0.2],...
    'fontsize',12,...
    'string','2');
%  Mf2 text box
ud.ph2.bmf2 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.65 0.45 0.3 0.2],...
    'fontsize',12,...
    'string','5');

% Mf text
ud.ph2.tb = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.05 0.1 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','beta: ');
%  Mf1 text box
ud.ph2.bb1 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.3 0.1 0.3 0.2],...
    'fontsize',12,...
    'string','0');
%  Mf2 text box
ud.ph2.bb2 = uicontrol('style','edit',...
    'Units', 'normalized',...
    'Parent',ud.ph2.panel,...
    'position',[0.65 0.1 0.3 0.2],...
    'fontsize',12,...
    'string','2');


%% another panel
% panel
ud.ph3.panel = uipanel('Units', 'normalized',...
    'position',[0.69 0.1 0.29 0.3],...
    'fontsize',14,...
    'Title','Output');

% text
ud.ph3.tz = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph3.panel,...
    'position',[0.05 0.8 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Z: ');
% pop-up menu
ud.ph3.pz = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.ph3.panel,...
    'position',[0.3 0.8 0.65 0.2],...
    'fontsize',14,...
    'string',ud.out.names,...
    'Value',1);

% text
ud.ph3.tc = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.ph3.panel,...
    'position',[0.05 0.5 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','C: ');
% pop-up menu
ud.ph3.pc = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.ph3.panel,...
    'position',[0.3 0.5 0.65 0.2],...
    'fontsize',14,...
    'string',ud.out.names,...
    'Value',2);
% Push button
ud.ph3.tc = uicontrol('style','pushbutton',...
    'Units', 'normalized',...
    'Parent',ud.ph3.panel,...
    'position',[0.15 0.2 0.65 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','PLOT',...
    'Callback','anjo.rankhug_gui(''plot'');');

set(gcf,'userdata',ud);
end


function ud = set_par(ud)

ud.N = 30;

% IN
ud.params.xpar = ud.ph1.px.String{ud.ph1.px.Value};
% ud.params.xval = linspace(1,90,ud.N);

ud.params.ypar = ud.ph1.py.String{ud.ph1.py.Value};
% ud.params.yval = linspace(2,5,ud.N);

xy = 'xy';

for l = 1:2
    switch ud.params.([xy(l),'par'])
        case 'th'
            ud.params.([xy(l),'val']) = linspace(str2double(ud.ph2.bth1.String),str2double(ud.ph2.bth2.String),ud.N);
        case 'Mf'
            ud.params.([xy(l),'val']) = linspace(str2double(ud.ph2.bmf1.String),str2double(ud.ph2.bmf2.String),ud.N);
        case 'beta'
            ud.params.([xy(l),'val']) = linspace(str2double(ud.ph2.bb1.String),str2double(ud.ph2.bb2.String),ud.N);
    end
end

% Out (redo)
ud.params.zpar = ud.ph3.pz.String(ud.ph3.pz.Value);
ud.params.cpar = ud.ph3.pc.String(ud.ph3.pc.Value);

end

function ud = plot_rankhug(ud)

% calculate first

upst = [];

% set fixed th if not selected
if ~strcmp(ud.params.xpar,'th') && ~strcmp(ud.params.ypar,'th')
    upst.th = str2double(ud.ph1.bth.String);
end
% set fixed Mf if not selected
if ~strcmp(ud.params.xpar,'Mf') && ~strcmp(ud.params.ypar,'Mf')
    upst.Mf = str2double(ud.ph1.bmf.String);
end
% set fixed beta if not selected
if ~strcmp(ud.params.xpar,'beta') && ~strcmp(ud.params.ypar,'beta')
    upst.beta = str2double(ud.ph1.bb.String);
end


z = zeros(ud.N,ud.N);
c = zeros(ud.N,ud.N);

zc = 'zc';

for j = 1:ud.N % x
    for k = 1:ud.N % y
        upst.(ud.params.xpar) = ud.params.xval(j);
        upst.(ud.params.ypar) = ud.params.yval(k);
        
        % do the calculation
        dnst = anjo.rankhug(upst);
        
        for l = 1:2
            switch ud.params.([zc(l),'par']){:}
                case ud.out.names{1} % nd/nu
                    eval([zc(l),'(j,k)=dnst.nd;'])
                case ud.out.names{2} % Bd/Bu
                    eval([zc(l),'(j,k)=norm(dnst.Bd);'])
                case ud.out.names{3} % Btd/Btu
                    eval([zc(l),'(j,k)=dnst.Bd(2)/sind(upst.th);'])
                case ud.out.names{4} % thd
                    eval([zc(l),'(j,k)=dnst.thd;'])
                case ud.out.names{5} % thd-th
                    eval([zc(l),'(j,k)=dnst.thd-upst.th;'])
                case ud.out.names{6} % Mdf
                    eval([zc(l),'(j,k)=dnst.Mdf;'])
                case ud.out.names{7} % betad
                    eval([zc(l),'(j,k)=dnst.betad;'])
                case ud.out.names{8} % Vd
                    eval([zc(l),'(j,k)=norm(dnst.Vd);'])
                case ud.out.names{9} % Vdn
                    eval([zc(l),'(j,k)=dnst.Vd(1);'])
                case ud.out.names{10} % Vdt
                    eval([zc(l),'(j,k)=dnst.Vd(2);'])
                case ud.out.names{11} % MdI
                    eval([zc(l),'(j,k)=dnst.MdI;'])
                case ud.out.names{12} % thdVn
                    eval([zc(l),'(j,k)=dnst.thdVn;'])
            end
        end
%             
%         z(j,k) = dnst.(ud.params.zpar);
%         c(j,k) = dnst.(ud.params.cpar);
        
    end
end

ud.hsf = surf(ud.ax,ud.params.xval,ud.params.yval,z');
ud.hsf.CData = c';

ud.hcb = colorbar(ud.ax,'Location','south');

ud.hcb.Position(2) = 0.1;
ud.hcb.AxisLocation = 'out';

% set x and y labels
xy = 'xy';
for l = 1:2
    switch ud.params.([xy(l),'par'])
        case 'th'
            anjo.label(ud.ax,xy(l),'$\theta_{Bn}$ [$^\circ$]')
        case 'Mf'
            anjo.label(ud.ax,xy(l),'$M_f$')
        case 'beta'
            anjo.label(ud.ax,xy(l),'$\beta$')
    end
end

% z and c labels
anjo.label(ud.ax,'z',ud.out.labels{ud.ph3.pz.Value})
anjo.label(ud.hcb,'y',ud.out.labels{ud.ph3.pc.Value})


% set title
if ~strcmp(ud.params.xpar,'th') && ~strcmp(ud.params.ypar,'th')
    title(ud.ax,['$\theta_{Bn} = ',num2str(upst.th),'^\circ$'],'interpreter','latex')
elseif ~strcmp(ud.params.xpar,'Mf') && ~strcmp(ud.params.ypar,'Mf')
    title(ud.ax,['$M_{f} = ',num2str(upst.Mf),'$'],'interpreter','latex')
elseif ~strcmp(ud.params.xpar,'beta') && ~strcmp(ud.params.ypar,'beta')
    title(ud.ax,['$\beta = ',num2str(upst.beta),'$'],'interpreter','latex')
end


end

