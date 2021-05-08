function [Hdraw,HvarsDraw,phi_Hdraw,Adraw,h0]=sampleH_Ben(yData,Psi,A,B,phi_H,HvarsOld,priorValues,dataValues,n,h0,HH)

%yData=YData
%Psi=PsiDraw_prop
%A=Adraw
%B=Bdraw
%phi_H=phi_Hdraw'
%HvarsOld=HvarsDraw
%% Initialize
offset_c=priorValues.offset_c; %constant for log transformation 

[T,M]=size(yData);
p = size(B,1)/M; %lags of the B vector that has dimensions MxM*p (no constant), each column is one regression

% obtain prior data
b0=priorValues.mean_ln_h0;  %log mean of the initial state (variance scaling parameters) as residuals from an AR(4) in the training sample
a0=eye(n)/priorValues.var_ln_h0(1,1);    %variance of the initial state for the elements of lambda

priorPhi_H=priorValues.phi_h;            %centering parameter for the inverse gamma of the variance of the innovations governing the random walk for lambda
priorD_H  =priorValues.d_h;              %scaling parameter for the inverse gamma distribution for the variance of the innovations governing the random walk for lambda

S_h = priorPhi_H*ones(n,1);
nu_h = 3*ones(n,1);
%% Prepare Data

Y_Psi=yData-Psi;  %subtract the local mean
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:)); %also generate initial conditions for the construction of the lagmatrix
X_Psi = lagmatrix(Y_Psi,1:p); %create RHS of the VAR part                          
X_Psi = X_Psi(p+1:end,:);     %remove the first p rows of RHS
Y_Psi=Y_Psi(p+1:end,:);       %and do so for LHS

E=Y_Psi-X_Psi*B;              %VAR residuals
Escaled=E*A';                 %transform such that VAR residuals have variance Lambda

Hvars=zeros(T,M);             %sampled states (diagonal elements of lambda)


%% Sample (States,Vars,phi)

for i=1:M
    % prepare for each i
    residsTemp=Escaled(:,i);
    yStar=log(residsTemp.^2+offset_c); %transform scaled residuals
    phi=phi_H(i); %previous draw for the variance of this particular variable
    lnSigma2=log(HvarsOld(p+1:T,i)); % note log => h = ln sigma2
    
    % sample offset mixture
    [yStarAdj, Ht] = statesMix(yStar,lnSigma2);

   % sample h conditional on the state 
    iSig_s = sparse(1:T-p,1:T-p,1./Ht); %state dependent variance
    Kh = HH/phi + iSig_s;
    h_hat = Kh\(h0(i,1)/phi*HH*ones(T-p,1) + iSig_s*(yStarAdj));
    logVarsDraw_Hi = h_hat + chol(Kh,'lower')'\randn(T-p,1);
    Hvars(:,i)=exp([zeros(1,p) logVarsDraw_Hi']');
    
 
    % sample phi
%     [phiDraw_Hi]=samplePhi(logVarsDraw_Hi,priorD_H,priorPhi_H);
%     phi_Hdraw(i)=phiDraw_Hi; 
    
    
end
    
   % sample phi 
    diff = (log(Hvars(p+1:end,:)) - [h0'; log(Hvars(p+1:end-1,:))]).^2;             
    phi_Hdraw = 1./gamrnd(nu_h + size(diff,1)/2, 1./(S_h + sum(diff)'/2))';    

% sample the initial value
    Kh0 = a0 + sparse(1:n,1:n,1./phi_Hdraw');
    h0_hat = Kh0\(a0*b0 + log(Hvars(p+1,:)')./phi_Hdraw');
    h0 = h0_hat + chol(Kh0,'lower')'\randn(n,1);    

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