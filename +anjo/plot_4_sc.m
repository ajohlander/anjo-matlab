function handles = plot_4_sc(varargin)

if ishandle(varargin{1})
    ids = 2;
    h = varargin{1};
else
    ids = 1;
    h = anjo.afigure(nargin,[10,8+(nargin-1)*2]);
end

for j = ids:nargin
        variable_str = varargin{j};
        c_eval('var?=evalin(''base'',irf_ssub(variable_str,?));');
        irf_pl_tx(h(j+1-ids),'var?')
        anjo.label(h(j+1-ids),variable_str)
end

% Just assume it's MMS (easy to change if not)
irf_legend(h(1),{'MMS1','MMS2','MMS3','MMS4'},[.02,1.02],'color','cluster','FontSize',15,'Interpreter','latex')

irf_plot_ylabels_align(h)

end