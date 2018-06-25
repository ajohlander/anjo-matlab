function [tau,dtau2] = time_lag(tint,S1,S2,S3,S4,varargin)
%ANJO.TIME_LAG Calculate time lag between 4 sc using mean square deviation
% 
% [tau,dtau] = ANJO.TIME_LAG(tint,X1,X2,X3,X4)
% 
% 
% Follows the procedure and notation of section 5 in: 
% Vogt, J., Haaland, S., and Paschmann, G.: 
% Accuracy of multi-point boundary crossing time analysis, 
% Ann. Geophys., 29, 2239-2252, 
% https://doi.org/10.5194/angeo-29-2239-2011, 2011.
%

% Ss are scalar timeseries objects

% Should allow guesses for tau!

%% Input
args = varargin;
nargs = length(args);

patternInput = 0;
startTau = -0.01*[1,1,1,1]; % starting guess for time differences
calcErrors = 1; % if error estimates should be calculated

have_options = nargs > 1;
while have_options
    switch(lower(args{1}))
        case 'p' % pattern
            P = args{2};
            patternInput = 1;
        case 'tau' % times
            % minus sign because I don't know
            startTau = -args{2};
        case 'calcerrors' % times
            calcErrors = args{2};
    end
    args = args(3:end);
    if isempty(args), break, end
end


%% Prepare analysis
% throw away data outside time interval

disp('Performing Timing analysis:')
disp('---------------------------')

% get sample time (assume constant)
Tsamp = median(diff(S1.time.epochUnix));

%% If no pattern in input -> fit to S1 and then construct average pattern

if ~patternInput
    % Get time differences with first sc as reference
    % The goal is to minimize eq (45) for each sc pair (mean square deviation)
    % get best time differences (for some reason start guess must be negative)
    disp('Getting time differences with first sc as reference...')
    tau12 = fminsearch(@(x) msdTS(x,S2,S1,tint),startTau(2));
    tau13 = fminsearch(@(x) msdTS(x,S3,S1,tint),startTau(3));
    tau14 = fminsearch(@(x) msdTS(x,S4,S1,tint),startTau(4));
    
    
    % Construct an average signal to use as pattern
    disp('Constructing an average signal to use as new pattern...')
    c_eval('S?p = S?; S?p.time = S?p.time+tau1?;',2:4)
    % new pattern
    P = 1/4*(S1+S2p.resample(S1)+S3p.resample(S1)+S4p.resample(S1));
    % start and stop times
    % c_eval('P = P.tlim([S?p.time(1),S?p.time(end)]);',2:4)
    P = P.tlim(tint);
    
    % debug
    figure; irf_pl_tx('S?p'); hold on; irf_plot(P,'c','linewidth',2)
    
    %redefine startTau
    startTau = [-0.01,tau12,tau13,tau14];
    
end

P = P.tlim(tint); % dont do this


%% Get time differences using the pattern
% c_eval has no power here!
disp('Getting time differences using pattern...')
tau1 = fminsearch(@(x) msdTS(x,S1,P,tint),startTau(1));
tau2 = fminsearch(@(x) msdTS(x,S2,P,tint),startTau(2));
tau3 = fminsearch(@(x) msdTS(x,S3,P,tint),startTau(3));
tau4 = fminsearch(@(x) msdTS(x,S4,P,tint),startTau(4));

% the minus is empirical
tau = -[tau1,tau2,tau3,tau4];


%% debug
% tau = linspace(-2,2);
% msd = zeros(size(tau));
% for ii = 1:length(tau)
%     msd(ii) = msdTS(tau(ii),S2,P,tint);
% end
% 
% figure;plot(tau,msd)


%% Get time difference errors
% The goal is to calculate eq (52)
if calcErrors
    
    % the time interval used for averaging (think its right)
    Tw = diff(P.time([1,end]).epochUnix)/2;
    
    % Define a time diff vector Delta
    Delta = P.time.epochUnix-mean(P.time.epochUnix);
    % number of points
    N = length(Delta);
    
    % get G (49)
    disp('Calculating G...')
    G = zeros(1,N);
    for ii = 1:N; G(ii) = corrG(Delta(ii),Tw,Tsamp,P,tint); end
    
    % Get H (50)
    c_eval('H?! = zeros(1,N);',1:4,1:4)
    % 16 times! wow
    disp('Calculating H...')
    disp('0%')
    for ii = 1:N; [H11(ii),h1] = corrH(Delta(ii),tau1,tau1,S1,S1,P); end
    for ii = 1:N; [H12(ii),h2] = corrH(Delta(ii),tau1,tau2,S1,S2,P); end
    for ii = 1:N; [H13(ii),h3] = corrH(Delta(ii),tau1,tau3,S1,S3,P); end
    for ii = 1:N; [H14(ii),h4] = corrH(Delta(ii),tau1,tau4,S1,S4,P); end
    disp('25%')
    for ii = 1:N; H21(ii) = corrH(Delta(ii),tau2,tau1,S2,S1,P); end
    for ii = 1:N; H31(ii) = corrH(Delta(ii),tau3,tau1,S3,S1,P); end
    for ii = 1:N; H41(ii) = corrH(Delta(ii),tau4,tau1,S4,S1,P); end
    for ii = 1:N; H22(ii) = corrH(Delta(ii),tau2,tau2,S2,S2,P); end
    disp('50%')
    for ii = 1:N; H23(ii) = corrH(Delta(ii),tau2,tau3,S2,S3,P); end
    for ii = 1:N; H24(ii) = corrH(Delta(ii),tau2,tau4,S2,S4,P); end
    for ii = 1:N; H32(ii) = corrH(Delta(ii),tau3,tau2,S3,S2,P); end
    for ii = 1:N; H42(ii) = corrH(Delta(ii),tau4,tau2,S4,S2,P); end
    disp('75%')
    for ii = 1:N; H33(ii) = corrH(Delta(ii),tau3,tau3,S3,S3,P); end
    for ii = 1:N; H34(ii) = corrH(Delta(ii),tau3,tau4,S3,S4,P); end
    for ii = 1:N; H43(ii) = corrH(Delta(ii),tau4,tau3,S4,S3,P); end
    for ii = 1:N; H44(ii) = corrH(Delta(ii),tau4,tau4,S4,S4,P); end
    disp('100%')
    
    
    
    Imin1 = msdTS(tau1,S1,P,tint);
    Imin2 = msdTS(tau2,S2,P,tint);
    Imin3 = msdTS(tau3,S3,P,tint);
    Imin4 = msdTS(tau4,S4,P,tint);
    dtau2 = zeros(4,4);
    
    % derivative of P
    Pp = P;
    Pp.data = [0;diff(P.data)/Tsamp]; % zero fill value

    % error through eq (52)
    c_eval('dtau2(?,!) = sqrt(Imin?*Imin!)/(N*mean(Pp.data.^2))*sum(G.*H?!);',1:4,1:4)
    
    disp('---------------------------')
    
    % Plot like Fig 5a. in the paper
    hca = anjo.afigure;
    plot(hca,Delta/Tsamp,h1,'Color','k')
    hold on
    plot(hca,Delta/Tsamp,h2,'Color','r')
    plot(hca,Delta/Tsamp,h3,'Color',[0,0.5,0])
    plot(hca,Delta/Tsamp,h4,'Color','b')
    
    % Plot like Fig 5b. in the paper
    h = irf_plot(1,'newfigure');
    hca = irf_panel(h,'GH');
    hold(hca,'on')
    grid(hca,'on')
    plot(hca,Delta/Tsamp,G.*H11,'Color','k')
    plot(hca,Delta/Tsamp,G.*H12,'Color','r')
    plot(hca,Delta/Tsamp,G.*H13,'Color',[0,0.5,0])
    plot(hca,Delta/Tsamp,G.*H14,'Color','b')
    ylabel(hca,'$G(\Delta)*H_{1,\beta}(\Delta)$','interpreter','latex')
    xlabel(hca,'$\Delta$ [s]','interpreter','latex')
    hca.FontSize = 15;
    
else
    dtau2 = 0;
end

end

% mean square deviation function
function [I,h] = msdTS(tau,S,P,tint)
% S is signal and P is pattern, here first sc is considered pattern

% time shift TS object
S.time = S.time+tau;

% start and stop times
tstart = tint(1).epochUnix;
tstop = tint(2).epochUnix;

S = S.resample(P);
% important to throw away data outside time interval
P.data(P.time.epochUnix<tstart | P.time.epochUnix>tstop) = 0;
S.data(S.time.epochUnix<tstart | S.time.epochUnix>tstop) = 0;

% get residual h (48)
h = (S.data-P.data);

% mean square deviation I (45)
I = mean(abs(h).^2);


end

function G = corrG(Delta,Tw,Tsamp,P,tint) % not really sure
% get G in eq (49)
% p-prime is the time derivative! See appendix B

% start and stop times
tstart = tint(1).epochUnix;
tstop = tint(2).epochUnix;


% get time derivative Pprime(t)
Pp = P;
Pp.data = [0;diff(P.data)/Tsamp]; % zero fill value

% get G in (49)
Ppd = Pp; Ppd.time = P.time+Delta; % P(t+Delta)
Ppd = Ppd.resample(P);
% important to throw away data outside time interval
Ppd.data(Ppd.time.epochUnix<tstart | Ppd.time.epochUnix>tstop) = 0;

G = (1-abs(Delta)/Tw)*mean((Pp.data.*Ppd.data))/(mean(Pp.data.^2));
end


function [Hab,hb] = corrH(Delta,tauStarA,tauStarB,Sa,Sb,P)
% get H in (50)

Sa.time = Sa.time+tauStarA;
Sb.time = Sb.time+tauStarB;

Sa = Sa.resample(P);
Sb = Sb.resample(P);

% residuals aafo time, eq (48)
ha = Sa.data-P.data;
hb = Sb.data-P.data;

	
hbTsDelta = irf.ts_scalar(P.time+Delta,hb);
hbTsDelta = hbTsDelta.resample(P);
hbDelta = hbTsDelta.data;

Hab = mean(ha.*hbDelta)/(sqrt(mean(ha.^2))*sqrt(mean(hb.^2)));


end









