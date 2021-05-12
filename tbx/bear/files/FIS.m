%______________________________________________________________________
function S = FIS(Y,Z,R,T,Q,S);
%FIS(y,C,R,A,Q,S)
%y=ystar; %(y in deviation from time varying mean)%Z=Zmatrix;
%R=LL; %(period specific VCV of measurement equation)
%Z=Zmatrix;
%T=Tmatrix;
%Q=QQ; %(%period specific VCV of transition equation)
%S= Estimates from Kalman filter SKF                                                          

%______________________________________________________________________
% Fixed intervall smoother (see Harvey, 1989, p. 154)
% FIS returns the smoothed state vector AmT and its covar matrix PmT             
% Use this in conjnuction with function SKF
%______________________________________________________________________
% INPUT  
%        Y         Data                                 (nobs x n)  
%        S Estimates from Kalman filter SKF                                                          
%          S.Am   : Estimates     a_t|t-1                  (nobs x m) 
%          S.Pm   : P_t|t-1 = Cov(a_t|t-1)             (nobs x m x m)
%          S.AmU  : Estimates     a_t|t                    (nobs x m) 
%          S.PmU  : P_t|t   = Cov(a_t|t)               (nobs x m x m)       
% OUTPUT 
%        S Smoothed estimates added to above
%          S.AmT  : Estimates     a_t|T                    (nobs x m) 
%          S.PmT :  P_t|T   = Cov(a_t|T)               (nobs x m x m)
%          S.PmT_1 : Cov(a_ta_t-1|T)
%        where m is the dim of state vector and t = 1 ...T is time

  [m ,nobs]       = size(S.Am);
  S.AmT           = zeros(m,nobs);
  S.PmT           = zeros(m,m,nobs);
  S.AmT(:,nobs)   = squeeze(S.AmU(:,nobs))  ;

  r = zeros(m,1);

  for t = nobs:-1:1
	[~,Z_t] = MissData(Y(:,t),Z,R,zeros(length(Y(:,t)),1));
    %r = Z*Ft^(-1)*Vt + Lt'*r_t-1
	r = S.ZF{t}*S.V{t}+(T*(eye(m)-squeeze(S.Pm(:,:,t))*S.ZF{t}*Z_t))'*r; %construct the period specific r by
    %S.ZF{t} = measurement equation matrix divided by variance of
    %prediction error given Y_t-1 = Z*F_t
	%S.V{t}  = prediction error for observation equation given Y_t-1 and A_t|t-1
    %S.Pm(:,:,t) = Pt+1|t predicted VCV of the state in for t+1 given Pt|t and Yt and using the period specific VCV of transition equation
    %Z_t = time invariant matrix of the observation equation
    %r = last period r
    %(T*(eye(m)-squeeze(S.Pm(:,:,t))*S.ZF{t}*Z_t))' = L' in the textbook
    %with L = Matrix of Transition equation - KalmanGain*Matrix of observation equation, 
    %which is the matrix linking the state forecast error in t+1 to the
    %state forecast error in T
    %S.Am(:,t) = Estimates     a_t|t-1
    S.AmT(:,t) = S.Am(:,t)+ squeeze(S.Pm(:,:,t))*r;
      
     
  end