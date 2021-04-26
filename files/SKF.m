%______________________________________________________________________
function S = SKF(Y,Z,R,T,Q,A_0,P_0,c1,c2)
%_____________________________________________________________________
% Kalman filter for stationary systems with time-varying system matrices
% and missing data.
%
% The model is        y_t   = Z * a_t + eps_t       
%                     a_t+1 = T * a_t + u_t       
%
%______________________________________________________________________
% INPUT  
%        Y         Data                                 (nobs x n)  
% OUTPUT 
%        S.Am       Predicted state vector  A_t|t-1      (nobs x m)  
%        S.AmU      Filtered  state vector  A_t|t        (nobs+1 x m)  
%        S.Pm       Predicted covariance of A_t|t-1      (nobs x m x m)  
%        S.PmU      Filtered  covariance of A_t|t        (nobs+1 x m x m)  
%        S.loglik   Value of likelihood function
% Y = ystar;
% Z = Zmatrix;
% R = LL;
% T= Tmatrix;
% Q = QQ;
% A_0 = x_0;
% P_0 = Pstart;
% c1 = zeros(size(Y,1),1);
% c2 = zeros(size(A,1),1); 

% Output structure & dimensions
  m = size(Z,2); %size of the Z matrix (observation equation matrix), which is of dimension (n+m, m+n*p)  
  nobs  = size(Y,2); %number of observations in Y (endogenous variables)
  
  S.Am  = nan(m,nobs);  %stores Predicted state vector  A_t|t-1  
  S.Pm  = nan(m,m,nobs); %stores Predicted covariance of A_t|t-1        
  S.AmU = nan(m,nobs);   %stores Filtered  state vector  A_t|t
  S.PmU = nan(m,m,nobs); %stores Filtered  covariance of A_t|t
  S.ZF = cell(nobs);     
  S.V = cell(nobs);      
  %______________________________________________________________________
  A = A_0;  % A_0|0; %set initial state
  P = P_0;  % P_0|0  %set initial state variance
  S.Am(:,1)    = A;
  S.Pm(:,:,1)  = P;

  for t = 1:nobs
%       t
      % A = A_t|t-1   & P = P_t|t-1

      
      % handling the missing data
      [y_t,Z_t,R_t,c1_t] = MissData(Y(:,t),Z,R(:,:,t),c1);
      
      if isempty(y_t)
          Au = A;
          Pu = P;
          ZF = zeros(m,0);
          V = zeros(0,1);
          
      else
          PZ = P*Z_t';       %covariance of predicted state and prediction error for observation given Y_t-1
          F  = Z_t*PZ + R_t; %variance of the prediction error for y_t given Y_t-1
          ZF = Z_t'/F;       %used to update Pt_t (variance of the state given Y_t) from P_t
          PZF = P*ZF;        %used to update Pt_t (variance of the state given Y_t) from P_t  
          
          
       %updating phase
          V   = y_t - Z_t*A-c1_t;  %prediction error of observation equation minus constant of observation
          Au  = A  + PZF * V;      %updated state given prediction error of observation equation
          Pu  = P  - PZF * PZ';    %updated variance of state given prediction error of observation equation
          Pu   =  0.5 * (Pu+Pu');
      end
      S.ZF{t} = ZF;           %store ZF (measurement equation matrix divided by variance of prediction error given Y_t-1) 
      S.AmU(:,t)   = Au;      %store updated state given prediction error of observation equation
      S.PmU(:,:,t) = Pu;      %updated variance of state given prediction error of observation equation
      S.V{t} = V;             %store prediction error of observation equation
      
      %prediction phase
      if t<nobs
          A   = T*Au+c2;      %predicted state for t+1 given At|t and Yt
          P   = T*Pu*T' + Q(:,:,t+1); %predicted VCV for t+1 given Pt|t and Yt and using the period specific VCV of transition equation
          P   =  0.5 * (P+P');
          S.Am(:,t+1)    = A;
          S.Pm(:,:,t+1)  = P;
      end
  end % t