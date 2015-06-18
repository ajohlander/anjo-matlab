function [varargout] = anjo(varargin)
%ANJO General info
%   
%   ANJO('path') Returns path to repo.
%
%   ANJO('ver') Returns version of repo.
%
%   Author: Andreas Johlander

if(nargin==0)
    help anjo
else
    pm = {'path','ver'};
    md = anjo.incheck(varargin,pm);
    
    switch lower(md)
        case 'path'
            varargout{1} = fileparts(which('anjo.m'));
        case 'ver'
            fid = fopen('+anjo/Contents.m');
            verstr = fgets(fid);
            varargout{1} = verstr(3:end);
    end
end
end

