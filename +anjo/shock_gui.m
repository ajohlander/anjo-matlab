function [out] = shock_gui(scd,varName)
%ANJO.SHOCK_GUI Gui for determining shock parameters
%
%   ANJO.SHOCK_GUI(scd) Starts a GUI. Select up- and downstream intervals
%   and calculate shock and upstream parameters.
%
%   Very much in beta.


%% handle input
if ischar(scd)
    % not first call
    ud = get(gcf,'userdata');
    switch scd
        case 'clu' % click upstream
            ud = clickt(ud,{'u'});
            ud = mark_times(ud);
            set(gcf,'userdata',ud)
        case 'cld' % click downstream
            ud = clickt(ud,{'d'});
            ud = mark_times(ud);
            set(gcf,'userdata',ud)
        case 'set_met' % click calculate
            ud = set_methods(ud);
            set(gcf,'userdata',ud)
        case 'calc' % click calculate
            ud.shp.nvec = anjo.shock_normal(ud.params);
            ud.shp.par = anjo.plasma_params(ud.params);
            ud.shp.data = ud.params;
            ud = display_prop(ud);
            set(gcf,'userdata',ud)
    end
else
    
    if nargin == 1
        varName = 'shock_params';
    end
    
    % number of inputs
    fn = fieldnames(scd);
    Nin = numel(fn);
    
    % find the position
    
    % possible inputs
    poss_inp = {'B','V','n','Ti','Te','R'};
    R.gseR1 = [0,0,0];
%     if ismember('R',poss_inp)
%         R = scd.R;
%     end
    for k = 1:Nin
        if ~ismember(fn{k},poss_inp)
                scd = rmfield(scd,fn{k});
                Nin = Nin-1;
        end
    end

    % initiate gui
    % user data
    ud = [];
    ud.Nin = Nin;
    ud.uih = [];
    %ud.R = R;
    ud = init_gui(ud);
    ud.params = [];
    ud.scd = scd;
    ud = avg_field(ud,scd,[]);
    ud = set_labels(ud);
    gfud = get(gcf,'userdata');
    ud.t_start_epoch = gfud.t_start_epoch;
    ud.tu = ud.t_start_epoch*[1;1];
    ud.td = ud.t_start_epoch*[1;1];
    ud.varName = varName;
    ud.shp.nvec = [];
    ud.shp.par = [];
    ud.normal_method = 'mx3';
    ud.vel_method = 'mf';

    %ud.txt.Ma = [];
    %ud.txt.thBn = [];
    set(gcf,'userdata',ud)
end

assignin('base',ud.varName, ud.shp)
if nargout == 1
    out = ud.shp;
end

end

function [ud] = init_gui(ud)

% initiate figure
% ax = irf_plot(ud.Nin,'newfigure');
ax = anjo.afigure(ud.Nin,[15,15]);

ax(1).Position(3) = 0.45;
for k = 1:ud.Nin
    ax(k).Position(1) = 0.1;
end
pause(0.001)
irf_plot_axis_align(ax);

ud.ax = ax;

%% Upstream panel
% panel
ud.uih.up.panel = uipanel('Units', 'normalized',...
    'position',[0.56 0.75 0.22 0.22],...
    'fontsize',14,...
    'Title','Upstream');
% push button for time 
ud.uih.up.pb = uicontrol('style','push',...
    'Units', 'normalized',...
    'Parent',ud.uih.up.panel,...
    'position',[0.05 0.5 0.8 0.3],...
    'fontsize',14,...
    'string','Click times',...
    'callback','anjo.shock_gui(''clu'')');

%% Downstream panel
% panel
ud.uih.dw.panel = uipanel('Units', 'normalized',...
    'position',[0.78 0.75 0.22 0.22],...
    'fontsize',14,...
    'Title','Downstream');
% push button for time 
ud.uih.dw.pb = uicontrol('style','push',...
    'Units', 'normalized',...
    'Parent',ud.uih.dw.panel,...
    'position',[0.05 0.5 0.8 0.3],...
    'fontsize',14,...
    'string','Click times',...
    'callback','anjo.shock_gui(''cld'')');

%% Method panel
% panel
ud.uih.mt.panel = uipanel('Units', 'normalized',...
    'position',[0.56 0.5 0.44 0.25],...
    'fontsize',14,...
    'Title','Methods');
% normal text
ud.uih.mt.ntx = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.uih.mt.panel,...
    'position',[0.05 0.7 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Normal: ');
% pop-up menu for normal method
ud.uih.mt.npu = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.uih.mt.panel,...
    'position',[0.35 0.7 0.4 0.2],...
    'fontsize',14,...
    'string',{'mc','vc','mx1','mx2','mx3'},...
    'Value',5,...
    'Callback','anjo.shock_gui(''set_met'')');

% velocity text
ud.uih.mt.vtx = uicontrol('style','text',...
    'Units', 'normalized',...
    'Parent',ud.uih.mt.panel,...
    'position',[0.05 0.3 0.3 0.2],...
    'fontsize',14,...
    'HorizontalAlignment','left',...
    'string','Velocity: ');
% pop-up menu for velocity method
ud.uih.mt.vpu = uicontrol('style','popupmenu',...
    'Units', 'normalized',...
    'Parent',ud.uih.mt.panel,...
    'position',[0.35 0.3 0.4 0.2],...
    'fontsize',14,...
    'string',{'gt','mf','sb'},...
    'Value',2,...
    'Callback','anjo.shock_gui(''set_met'')');

%% Calculate panel
% panel
ud.uih.cl.panel = uipanel('Units', 'normalized',...
    'position',[0.56 0.05 0.44 0.45],...
    'fontsize',14,...
    'Title','Shock parameters');

% push button
ud.uih.cl.pb = uicontrol('style','push',...
    'Units', 'normalized',...
    'position',[0.2 0.8 0.6 0.2],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','Calculate',...
    'callback','anjo.shock_gui(''calc'')');

ud.uih.cl.nvec = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.05 0.6 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','n = ');

ud.uih.cl.Vsh = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.05 0.45 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','Vsh = ');

ud.uih.cl.thBn = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.05 0.3 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','thBn = ');

ud.uih.cl.thVn = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.05 0.15 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','thVn = ');



% second column
ud.uih.cl.Ma = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.505 0.6 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','Ma = ');

ud.uih.cl.Mms = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.505 0.45 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','Mf = ');

ud.uih.cl.bi = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.505 0.3 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','beta_i = ');

ud.uih.cl.be = uicontrol('style','text',...
    'Units', 'normalized',...
    'position',[0.505 0.15 0.4 0.15],...
    'fontsize',14,...
    'Parent',ud.uih.cl.panel,...
    'HorizontalAlignment','left',...
    'string','beta_e = ');


ud.params = [];

end

function [ud] = clickt(ud,str)
ud = avg_field(ud,ud.scd,str);
end

function [ud] = mark_times(ud)
disp('mark')
for k = 1:ud.Nin
    delete(findall(ud.ax(k).Children,'Tag','irf_pl_mark'));
end
pause(0.001)

ucol = [0.7,0.7,0];
dcol = [0,0.7,0.7];

%irf_pl_mark(ud.ax,ud.tu',ucol)
%irf_pl_mark(ud.ax,ud.td',dcol)

end

function [ud] = set_methods(ud)
    ud.normal_method = ud.uih.mt.npu.String{ud.uih.mt.npu.Value};
    ud.vel_method = ud.uih.mt.vpu.String{ud.uih.mt.vpu.Value};
end

function [ud] = display_prop(ud)
nstr = ['[',num2str(round(ud.shp.nvec.n.(ud.normal_method)(1),2)),',',...
    num2str(round(ud.shp.nvec.n.(ud.normal_method)(2),2)),',',...
    num2str(round(ud.shp.nvec.n.(ud.normal_method)(3),2)),']'];
ud.uih.cl.nvec.String = ['n = ',nstr];
ud.uih.cl.thBn.String = ['thBn = ',num2str(round(ud.shp.nvec.thBn.(ud.normal_method),2))];
ud.uih.cl.thVn.String = ['thVn = ',num2str(round(ud.shp.nvec.thVn.(ud.normal_method),2))];
% Alfven mach
if isfield(ud.shp.par,'Mau')
    ud.uih.cl.Ma.String = ['Ma = ',num2str(round(ud.shp.par.Mau,2))];
end
% MS mach
if isfield(ud.shp.par,'Mfu')
    ud.uih.cl.Mms.String = ['Mf = ',num2str(round(ud.shp.par.Mfu,2))];
end
% ion beta
if isfield(ud.shp.par,'biu')
    ud.uih.cl.bi.String = ['beta_i = ',num2str(round(ud.shp.par.biu,2))];
end
% electron beta
if isfield(ud.shp.par,'beu')
    ud.uih.cl.be.String = ['beta_e = ',num2str(round(ud.shp.par.beu,2))];
end
% shock speed
ud.uih.cl.Vsh.String = ['Vsh = ',num2str(round(ud.shp.nvec.Vsh.(ud.vel_method).(ud.normal_method),0)),' km/s'];


end

function [ud] = avg_field(ud,par,fin)
%AVG_FIELD Calculates average value in a time interval
%   out = AVG_FIELD(ud,par,fin)
%
%   Examples:
%           par =
%               B: [1x1 TSeries]
%
%       >> avg = avg_field(ud,par,{'avg'});
%           out =
%               Bavg: [1.52,2.53,-0.22]
%
% -------------------------------------
%           par =
%               B: [1x1 TSeries]
%               V: [1x1 TSeries]
%
%       >> avg = avg_field(ud,par,{'u','d'});
%           out =
%               Bu: ...
%               Bd: ...
%               Vu: ...
%               Vd: ...



% number of parameter inputs
fnp = fieldnames(par);
nin = numel(fnp);

N = numel(fin);


% Plot all inputs only first time
if isempty(ud.ax(1).Tag)
    for k = 1:nin
        if ~strcmpi(fnp{k},'r')
        irf_plot(ud.ax(k),par.(fnp{k}));
        ud.ax(k).Tag = fnp{k};
        end
    end
end

% align time axis
tint = par.(fnp{1}).time([1,end]); % not optimal
irf_zoom(ud.ax,'x',tint)

% Set color order (this is done twice for some reason)
color_order = zeros(nargout*3,3);
for i = 1:3:nargout*3
    color_order(i:i+2,:) = [0,0,0; 0,0,1; 1,0,0];
end
for k = 1:nin
    ud.ax(k).ColorOrder = color_order;
end

% Give some log, should probably be "mark upstream/downstream"
irf.log('w',['Mark ',num2str(nargout), ' time intervals for averaging.'])

% Nested loop for calculating averages
for i = 1:N
    % Click times
    [t,~] = ginput(2);
    t = sort(t);
    fig = gcf;
    t = t+fig.UserData.t_start_epoch;
    ud.(['t',fin{i}]) = t;
    
    for k = 1:nin
        % variable
        X = par.(fnp{k});
        % find time indicies (change from anjo)
        idt = anjo.fci(t,X.time.epochUnix,'ext');
        tinti = X.time(idt).epochUnix';
        % mark selected time
        %irf_pl_mark(ud.ax(k),tinti)
        hold(ud.ax(k),'on')
        % Calculate average
        x_avg = double(nanmean(X.data(idt(1):idt(2),:)));
        % Plot average as solid lines lines
        delete(findall(ud.ax(k).Children,'Tag',['avg_mark',fin{i}]))
        irf_plot(ud.ax(k),[tinti',[x_avg;x_avg]],'Tag',['avg_mark',fin{i}])
        ud.ax(k).ColorOrder = color_order;
        ud.params.([fnp{k},fin{i}]) = x_avg;
    end
end
if ~isempty(ud.params)
    ud.params = orderfields(ud.params);
end
end


function ud = set_labels(ud)
% array of tags
%tagAr = {'B','V','n','Ti','Te'};


for k = 1:ud.Nin
    switch ud.ax(k).Tag
        case 'B'
            ud.ax(k).YLabel.String = 'B (nT)';
        case 'V'
            ud.ax(k).YLabel.String = 'V (km/s)';
        case 'n'
            ud.ax(k).YLabel.String = 'n (cm^-^3)';
        case 'Ti'
            ud.ax(k).YLabel.String = 'Ti (eV)';
        case 'Te'
            ud.ax(k).YLabel.String = 'Te (eV)';
        otherwise
            ud.ax(k).YLabel.String = ':P';
    end
end
end
