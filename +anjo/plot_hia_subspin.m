function [hsf,ionMat,t] = plot_hia_subspin(AX,tint,scInd,plotMode,colLim)
%ANJO.PLOT_HIA_SUBSPIN plots data from HIA in phase space density [s^3km^-6].
%   [hsf,ionMat,t] = ANJO.PLOT_HIA_SUBSPIN(AX,tint,scInd,mode,colLim) plots
%   HIA data in phase space density. Returns data in ionMat and time vector
%   t. Input tint is the time interval for the data, scInd is the
%   spacecraft number (1 or 3) and colLim is the limits of the colorbar.
%
%   mode:
%       'default'   - returns full 4-D matrix.
%       'energy'    - integrates over polar angle
%
%   See also: ANJO.GET_HIA_DATA
%
%   ONLY WORKS FOR SUBSPIN DATA

tintData = [tint(1)-12,tint(2)+12];
[ionMat,t] = anjo.get_hia_data(tintData,scInd,plotMode);
[th,~,etab] = anjo.get_hia_values('all');

hideXLabel = isequal(get(AX,'XTickLabel'),[]);



fPar = AX.Parent;
if(~isfield(fPar.UserData,'t_start_epoch'))
    fPar.UserData.t_start_epoch = tint(1);
end


P.p = ionMat;
P.t = t;

switch plotMode
    case 'energy'
        P.f = etab;
        hsf = irf_spectrogram(AX,P);
        labStr = 'Energy [eV]';
        AX.YScale = 'log';
    case 'polar'
        P.f = th;
        hsf = irf_spectrogram(AX,P);

        labStr = '$\theta$ [deg]';
        %h.YTick = [1e1, 1e2, 1e3, 1e4];
        %h.YLim = [0,180];
end

irf_zoom(AX,'x',tint)

anjo.label(AX,labStr)
legStr = ['C',num2str(scInd)];%,'\_CP\_CIS-HIA\_HS\_MAG\_IONS\_PSD'];
hleg = irf_legend(AX,{legStr},[0.98,0.95]);
hleg.Color = 'y';

if(hideXLabel)
    set(AX,'XTickLabel',[])
else
    irf_timeaxis(AX)
end


end
