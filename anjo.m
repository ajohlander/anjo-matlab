function [varargout] = anjo(varargin)
%ANJO General info
%   
%   ANJO('check') Checks versions of anjo-matlab and irf-matlab.
%
%   ANJO('help') Same as help anjo.
%
%   ANJO('path') Returns or prints path to repo.
%
%   ANJO('ver') Returns version of repo.
%
%   Author: Andreas Johlander


    pm = {'check','help','path','ver'};
    md = anjo.incheck(varargin,pm);
    
    switch lower(md)
        case 'check'
            disp(['anjo-matlab ',anjo('ver')])
            irf('check')
        case 'help'
            help anjo
        case 'path'
            varargout{1} = fileparts(which('anjo.m'));
        case 'ver'
            fid = fopen('+anjo/Contents.m');
            verstr = fgets(fid);
            if(nargout == 1)
                varargout{1} = verstr(3:end);
            else
                fprintf(verstr(3:end));
            end
    end

end

