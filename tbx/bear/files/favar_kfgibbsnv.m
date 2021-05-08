function Sdraw=favar_kfgibbsnv(data,S0,P0,H,R,F,Q,indexnM)
%function Sdraw=kfgibbs(data,S0,P0,H,R,F,Q)
% generates one gibbs draw of a vector (matrix) sdraw of unobservable state
% kalman filter is used to obtain state means and variances given starting values and parameters
% next last observation is drawn from normal with mean and variance as given by last iteration of KF
% then next to last observation on state from KF is updated using this draw
% this way we iterate, drawing from normal at each step, to the beginning of sample
% observation equation: y(t) = Hs(t) + e(t)         e ~ iidN(0,R)
% state equation:       s(t) = Fs(t-1) + v(t)       v ~ iidN(0,Q)       e,v uncorrelated
% llh is log likelihood value
% based on Kim & Nelson (1999) "State-Space Models With Regime Switching", page 192
% indexnM specifies prior distribution, see  favnv.m for details
% Piotr Eliasz, 12/1/2002
[t,~]=size(data);
kml=size(S0,1);
km=size(H,2);
% KF
Sp=S0;  % p for prediction: S(t|t-1), Stt denotes S(t|t)
Pp=P0;
S=zeros(t,kml);
P=zeros(kml^2,t);
for i=1:t
    y = data(i,:)';
    nu = y - H*Sp(1:km);   % conditional forecast error
    f = H*Pp(1:km,1:km)*H' + R;    % variance of the conditional forecast error

    finv=H'/f;
    
    Stt = Sp + Pp(:,1:km)*finv*nu;
    Ptt = Pp - Pp(:,1:km)*finv*(H*Pp(1:km,:));
    
    if i < t
        Sp = F*Stt;
        Pp = F*Ptt*F' + Q;
    end
    
    S(i,:) = Stt';
    P(:,i) = reshape(Ptt,kml^2,1);
end

% draw Sdraw(T|T) ~ N(S(T|T),P(T|T))
Sdraw=zeros(t,kml);
Sdraw(t,:)=S(t,:);
%%% rounding errors
%Ptt_input = (Ptt(indexnM,indexnM) + Ptt(indexnM,indexnM).')/2;
%Ptt_input=Ptt(indexnM,indexnM);
Sdraw(t,indexnM)=favar_mvnrnd(Sdraw(t,indexnM)',Ptt(indexnM,indexnM),1);

% iterate 'down', drawing at each step, use modification for singular Q
Qstar=Q(1:km,1:km);
Fstar=F(1:km,:);

for i=1:t-1
    Sf = Sdraw(t-i+1,1:km)';
    Stt = S(t-i,:)';
    Ptt = reshape(P(:,t-i),kml,kml);
    f = Fstar*Ptt*Fstar' + Qstar;
    finv = Fstar'/f;
    nu = Sf - Fstar*Stt;
    
    Smean = Stt + Ptt*finv*nu;
    Svar = Ptt - Ptt*finv*(Fstar*Ptt);
    
    Sdraw(t-i,:) = Smean';
    %%% rounding errors
    %Svar_input = (Svar(indexnM,indexnM) + Svar(indexnM,indexnM).')/2;
    %Svar_input=Svar(indexnM,indexnM);
    Sdraw(t-i,indexnM)=favar_mvnrnd(Sdraw(t-i,indexnM)',Svar(indexnM,indexnM),1);
end
Sdraw=Sdraw(:,1:km);