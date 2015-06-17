function [varargout] = anjo(varargin)
%ANJO General info
%   
%   ANJO('path') Returns path to repo.
%   
%   Author: Andreas Johlander

if(nargin==0)
    help anjo
else
    pm = {'path'};
    md = anjo.incheck(varargin,pm);
    
    switch lower(md)
        case 'path'
            varargout{1} = fileparts(which('anjo.m'));
    end
end
end

