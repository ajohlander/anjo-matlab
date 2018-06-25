function [] = print_pdf(h,fileName)

if isnumeric(h)
    fig = figure(h);
elseif strcmpi(h.Type,'axes')
    fig = h.Parent;
elseif strcmpi(h.Type,'figure')
    fig = h;
end


fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
fig.Renderer = 'Painters';
print(fig,fileName,'-dpdf','-bestfit')
end