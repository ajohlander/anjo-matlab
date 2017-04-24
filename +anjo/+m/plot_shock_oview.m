function handles = plot_shock_oview(B,E,ni,ne,vi,ve,fi,fe)

handles = [];
handles.h = anjo.afigure(7,[12,14]);

% Magnetic field
hca = irf_panel(handles.h,'Bxyz');
irf_plot(hca,B);
hold(hca,'on')
irf_plot(hca,B.abs,'Color',[0,.5,0]);
anjo.label(hca,'y','$\mathbf{B}$ [nT]')
handles.leg1 = irf_legend(hca,{'$B_x$','$B_y$','$B_z$','$|\mathbf{B}|$'},[.98,.98],'interpreter','latex','fontsize',15);
hca.YLimMode = 'auto';


% Electric field
hca = irf_panel(handles.h,'Exyz');
irf_plot(hca,E);
anjo.label(hca,'y','$\mathbf{E}$ [mV/m]')
handles.leg2 = irf_legend(hca,{'$E_x$','$E_y$','$E_z$'},[.98,.98],'interpreter','latex','fontsize',15);
hca.YLimMode = 'auto';

% Density
hca = irf_panel(handles.h,'n');
irf_plot(hca,ni);
hold(hca,'on')
irf_plot(hca,ne);
anjo.label(hca,'y','$N$ [cm$^{-3}$]')
handles.leg3 = irf_legend(hca,{'$N_i$','$N_e$'},[.98,.98],'interpreter','latex','fontsize',15);
hca.YLimMode = 'auto';

% Ion velocity
hca = irf_panel(handles.h,'Vi');
irf_plot(hca,vi);
anjo.label(hca,'y','$\mathbf{V}_i$ [km/s]')
handles.leg4 = irf_legend(hca,{'$V_x$','$V_y$','$V_z$'},[.98,.98],'interpreter','latex','fontsize',15);
hca.YLimMode = 'auto';

% Electron velocity
hca = irf_panel(handles.h,'Ve');
irf_plot(hca,ve);
anjo.label(hca,'y','$\mathbf{V}_e$ [km/s]')
handles.leg4 = irf_legend(hca,{'$V_x$','$V_y$','$V_z$'},[.98,.98],'interpreter','latex','fontsize',15);
hca.YLimMode = 'auto';

% Ion energy distribution
hca = irf_panel(handles.h,'fi');
[~,handles.hcb1] = irf_spectrogram(hca,fi.omni.specrec);
anjo.cmap(hca,'irf')
anjo.label(hca,'$E_i$ [eV]');
hca.YScale = 'log';
hca.YTick = 10.^[1,2,3,4];
handles.hcb1.Label.String{2} = 's$^3$cm$^{-6}$';
handles.hcb1.Label.Interpreter = 'latex';
anjo.box(hca,'on')

% Electron energy distribution
hca = irf_panel(handles.h,'fe');
[~,handles.hcb2] = irf_spectrogram(hca,fe.omni.specrec);
anjo.cmap(hca,'irf')
anjo.label(hca,'$E_e$ [eV]');
hca.YScale = 'log';
hca.YTick = 10.^[1,2,3,4];
handles.hcb2.Label.String{2} = 's$^3$cm$^{-6}$';
handles.hcb2.Label.Interpreter = 'latex';
anjo.box(hca,'on')


%% test
pause(0.2)
% title
handles.title = irf_legend(handles.h(1),['MMS',E.name(4)],[.01,1.03],'interpreter','latex','fontsize',15);

irf_zoom(handles.h,'x',B.time([1,length(B.time)]))

irf_plot_axis_align(handles.h)

for k = 1:length(handles.h)
    pause(.1)
    irf_zoom(handles.h(k),'y',handles.h(k).YLim)
    handles.h(k).LineWidth = 1;
end



end