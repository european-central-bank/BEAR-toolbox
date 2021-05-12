function [Hdraw,HvarsDraw,phi_Hdraw,Adraw,h0,Kh0]=sampleH_update(yData,Psi,A,B,phi_H,HvarsOld,priorValues,dataValues,h0,Kh0)
% this function samples the stochastic covariance matrix H. The steps are
% (1) the states s, (2) the log variances, (3) the phi parameters, and (4)
% the matrix A.
%yData=YData
%Psi = PsiDraw_prop; %draw for the local mean
%A=Adraw;            %draw for the A matrix (constant part of H=VCV_VAR),
%H=A^-1*Lambda*A^-1'
%B = Bdraw; %VAR coefficients
%phi_H =phi_Hdraw; %volatitilty of innovations in random walk for the elemnts of Lambda (stochastic volatility parameters)
%HvarsOld = HvarsDraw; %H from previous iteration
%% Initialize
offset_c=priorValues.offset_c; %constant for log transformation 

[T,M]=size(yData);
n=M;
p = size(B,1)/M; %lags of the B vector that has dimensions MxM*p (no constant), each column is one regression

% obtain prior data
%startMeanVector=priorValues.mean_ln_h0;  %log mean of the initial state (variance scaling parameters) as residuals from an AR(4) in the training sample
%startVarVector=priorValues.var_ln_h0;    %variance of the initial state for the elements of lambda

% obtain prior data
b0=priorValues.mean_ln_h0;  %log mean of the initial state (variance scaling parameters) as residuals from an AR(4) in the training sample
a0=eye(M)/priorValues.var_ln_h0(1,1);    %variance of the initial state for the elements of lambda

priorPhi_H=priorValues.phi_h;            %centering parameter for the inverse gamma of the variance of the innovations governing the random walk for lambda
priorD_H  =priorValues.d_h;              %scaling parameter for the inverse gamma distribution for the variance of the innovations governing the random walk for lambda

S_h = priorPhi_H*ones(n,1);
nu_h = priorD_H*ones(n,1);

%% Prepare Data

Y_Psi=yData-Psi;  %subtract the local mean
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:)); %also generate initial conditions for the construction of the lagmatrix
% X_Psi = lagmatrix(Y_Psi,1:p); %create RHS of the VAR part                          
X_Psi = lagx(Y_Psi,p-1);
X_Psi = X_Psi(1:end-1,:);
% X_Psi = X_Psi(p+1:end,:);     %remove the first p rows of RHS
Y_Psi=Y_Psi(p+1:end,:);       %and do so for LHS

E=Y_Psi-X_Psi*B;              %VAR residuals
Escaled=E*A';                 %transform such that VAR residuals have variance Lambda

Hvars=zeros(T,M);             %sampled states (diagonal elements of lambda)
%phi_Hdraw=zeros(1,M);         %variance of the random walk process governing the elements of lambda


%% Sample (States,Vars,phi)

for i=1:M
    % prepare for each i
    residsTemp=Escaled(:,i);
    yStar=log(residsTemp.^2+offset_c); %transform scaled residuals
    phi=phi_H(i); %previous draw for the variance of this particular variable
    lnSigma2=log(HvarsOld(p+1:T,i)); % note log => h = ln sigma2
    
    startMean=h0(i); %variable specific mean of the initial condition for the  volatility 
    startVar=Kh0(i,i);   %variable specific variance of the disturbances of the random walk for the volatility process
    
    % sample states
    [yStarAdj, Ht] = statesMix(yStar,lnSigma2);
    
    % sample log variances
    [logVarsDraw_Hi]=KF_CKsimSV(yStarAdj,Ht,phi,startMean,startVar);
    Hvars(:,i)=exp([zeros(1,p) logVarsDraw_Hi']');
    
%     % sample phi
%     [phiDraw_Hi]=samplePhi(logVarsDraw_Hi,priorD_H,priorPhi_H);
%     phi_Hdraw(i)=phiDraw_Hi;   
end

  %sample phi
%   for kk=1:n
%    [phiDraw_Hi]=samplePhi([h0(kk,1); log(Hvars(p+1:end,kk))],priorD_H,priorPhi_H);
%    phi_Hdraw(1,kk)=phiDraw_Hi;
%   end
  
for kk=1:n
logSVseries=[h0(kk,1); log(Hvars(p+1:end,kk))];
  %% Initialize
T1=length(logSVseries);
vDiffSV=(logSVseries(2:T1)-logSVseries(1:T1-1));

%% posteror parameter values
a1=priorD_H*priorPhi_H+sum(vDiffSV.^2); %scale parameter
b1=priorD_H+(T1-1); %shape parameter

%% Take a draw form the posterior distribution
gammaDraw=grandn(b1/2,2/a1);
phiDrawkk=1/gammaDraw;
phi_Hdraw(1,kk)=phiDrawkk;
end  
    % sample phi 
     
%diff = (log(Hvars(p+1:end,:)) - [h0'; log(Hvars(p+1:end-1,:))]).^2;  
%phi_Hdraw = 1./gamrnd(nu_h + size(diff,1)/2, 1./(S_h + sum(diff)'/2))';   
%phi_Hdraw = 1./gamrnd(S_h + size(diff,1)/2, 1./((nu_h.*S_h) + sum(diff)'/2))';   
    
% 
% % sample the initial value
Kh0 = a0 + sparse(1:n,1:n,1./phi_Hdraw');
h0_hat = Kh0\(a0*b0 + log(Hvars(p+1,:)')./phi_Hdraw');
h0 = h0_hat + chol(Kh0,'lower')'\randn(n,1);   

    %h0 = priorValues.mean_ln_h0; %initialize initial variance 
    %Kh0 = diag(priorValues.var_ln_h0); %initialize initial variance 

%% Sample A
[Adraw]=sampleA_H(yData,Psi,B,Hvars,T,priorValues,dataValues);
AdrawInv=Adraw\eye(M);

%% Construct H
Hdraw=zeros(M,M,T);


for t=1:T
    Hdraw(:,:,t)=AdrawInv*diag(Hvars(t,:))*AdrawInv';
end
 
HvarsDraw=Hvars;
 
end

