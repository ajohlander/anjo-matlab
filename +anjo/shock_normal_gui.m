function [nd] = shock_normal_gui(B,V,fullOutput)
%SHOCK_NORMAL_GUI Summary of this function goes here
% Shock angle > 90 deg is difficult
if nargin == 2
    fullOutput = 0;
end

[Bu,Bd,Vu,Vd] = get_fields(B,V);

tint_u = Vu([1,end],1);
tint_d = Vd([1,end],1);

N = floor(size(Bu,1)/2);

t_u = rand(1,N)*(tint_u(2)-tint_u(1))+tint_u(1);
t_d = rand(1,N)*(tint_d(2)-tint_d(1))+tint_d(1);


%thBn = zeros(1,N);
for k = 1:N
    
    % field for given time
    Bu_r = irf_resamp(Bu,t_u(k));
    Bd_r = irf_resamp(Bd,t_d(k));
    
    Vu_r = irf_resamp(Vu,t_u(k));
    Vd_r = irf_resamp(Vd,t_d(k));

    spec = [];
    spec.Bu = Bu_r(1,2:4);
    spec.Bd = Bd_r(1,2:4);
    spec.Vu = Vu_r(1,2:4);
    spec.Vd = Vd_r(1,2:4);

    ndk = anjo.shock_normal(spec,0);
    
    % first call initialize structs
    if k == 1
        fnames = fieldnames(ndk.n);
        thBn = ndk.thBn;
        for i = 1:length(fnames)
            thBn.(fnames{i}) = zeros(1,N);
        end
    end
    
    for i = 1:length(fnames)
            thBn.(fnames{i})(k) = ndk.thBn.(fnames{i});
    end
    

    %     thBn(k) = nd.thBn.vc;
%     thBn(k) = nd.thBn.vc;
%     thBn(k) = nd.thBn.vc;
%     thBn(k) = nd.thBn.vc;
%     
%     
%     if isnan(thBn(k))
%         disp('oi!')
%     end
%     
end

nd = [];
if fullOutput
    nd.thBn = thBn;
else
    th_fun = @(x)(mean(x)>90)*180+(-1)^(mean(x)>90)*mean(x);
    nd.thBn = structfun(th_fun,thBn,'UniformOutput',0);
    nd.dthBn = structfun(@(th)std(th),thBn,'UniformOutput',0);
end

end

function [Bu,Bd,Vu,Vd] = get_fields(B,V)
%AVG_FIELD Summary of this function goes here
%   Detailed explanation goes here

[h,f] = anjo.afigure(2,[15,8]);

irf_plot(h(1),B);

irf_plot(h(2),V)
irf_plot_axis_align(h);


irf.log('w',['Mark ',num2str(2), ' time intervals for averaging.'])

%varargout = cell(1,nargout);   
id = 'ud';
for i = 1:2
    [t,~] = ginput(2);
    t = sort(t);
    t = t+f.UserData.t_start_epoch;
    
    idt_b = anjo.fci(t,B.time.epochUnix,'ext');
    idt_v = anjo.fci(t,V.time.epochUnix,'ext');
    tint = B.time(idt_b).epochUnix';
    irf_pl_mark(h,tint)

    B_int = [B.time(idt_b(1):idt_b(2)).epochUnix,double([B.x.data(idt_b(1):idt_b(2)),B.y.data(idt_b(1):idt_b(2)),B.z.data(idt_b(1):idt_b(2))])];
        
    V_int = [V.time(idt_v(1):idt_v(2)).epochUnix,double([V.x.data(idt_v(1):idt_v(2)),V.y.data(idt_v(1):idt_v(2)),V.z.data(idt_v(1):idt_v(2))])];

    c_eval('B?=B_int;',id(i))
    c_eval('V?=V_int;',id(i))
end
end
