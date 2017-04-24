function [vp,Et_out] = vp_monochrom(E,B,k_hat,tint,varargin)
%VP_MONOCHROM Single sc method to calculate phase speed of monochromatic
%waves.
% 
%   vp = VP_MONOCHROM(E,B,k_hat,tint) Returns phase speed vp given electric
%   field E, magnetic field B, and k_hat unit vector from e.g. MVA.
% 
%   
%
%function [vp,Rval,Et_out] = vp_monochrom(E,B,k_hat,tint,fmin,fmax,min_met)

if nargin == 5
    min_met = 'abs';
end

if nargin == 6
    min_met = varargin{2};
end

% Filter if fmin and fmax inputted. Uses order=5
if nargin > 4
    if ischar(varargin{1})
        min_met = varargin{1};
        doFilt = 0;
    else
        doFilt = 1;
        fmin = varargin{1}(1);
        fmax = varargin{1}(2);
    end
end

% just use B's time resolution
tt = B.time(B.time>=tint(1) & B.time<=tint(2));

% number of data points
N = tt.length;
% TSeries object just containing k_hat
khTS = B.resample(tt);
khTS.data = repmat(k_hat,N,1); % use k_hat from MVA

switch min_met
    case 'abs'
        % initiate a TSeries object
        Et = E;
        % Compute Et
        Et.data = E.data-E.dot(k_hat).data*k_hat;
        
        if doFilt
            Etr = irf_filt(Et.resample(tt),fmin,fmax,[],5);
            Br = irf_filt(B.resample(tt),fmin,fmax,[],5);
        end
        
        % Resample
        %Br = B.resample(tt);
        %Etr = Et.resample(tt);
        
        ai = Etr.data*1e-3;
        bi = khTS.cross(Br).data*1e-9;
        
        vp = -sum(sum(ai.*bi,2))/sum(sum(bi.*bi,2))*1e-3;
        
    case 'xy'
        s_hat = cross(k_hat,[0,0,1])/norm(cross(k_hat,[0,0,1]));
        
        if doFilt
            Er = irf_filt(E.resample(tt),fmin,fmax,[],5);
            Br = irf_filt(B.resample(tt),fmin,fmax,[],5);
        end
        
        % Resample
        %Br = B.resample(tt);
        %Er = E.resample(tt);
       
        ai = Er.dot(s_hat).data*1e-3;
        bi = khTS.cross(Br).dot(s_hat).data*1e-9;
        
        vp = -sum(ai.*bi)/sum(bi.^2)*1e-3;
    otherwise
        error('Get outta here!')
end


if nargout == 2 % return constructed Et given calculated vp
    Et_out = E.resample(tt);
    Et_out.data = vp*Br.cross(khTS).data*1e-3;
end



end

