function [Hdraw,HvarsDraw,phi_Hdraw,Adraw,h0]=sampleH_MHstep(yData,Psi,A,B,phi_H,HvarsOld,priorValues,dataValues,n,h0)

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
startMeanVector=priorValues.mean_ln_h0;  %log mean of the initial state (variance scaling parameters) as residuals from an AR(4) in the training sample
startVarVector=priorValues.var_ln_h0;    %variance of the initial state for the elements of lambda

% obtain prior data
b0=priorValues.mean_ln_h0;  %log mean of the initial state (variance scaling parameters) as residuals from an AR(4) in the training sample
a0=eye(M)/priorValues.var_ln_h0(1,1);    %variance of the initial state for the elements of lambda

priorPhi_H=priorValues.phi_h;            %centering parameter for the inverse gamma of the variance of the innovations governing the random walk for lambda
priorD_H  =priorValues.d_h;              %scaling parameter for the inverse gamma distribution for the variance of the innovations governing the random walk for lambda

kappa= priorValues.kappa;
gamma= 1; %priorValues.gamma;

S_h = priorPhi_H*ones(n,1);
nu_h = priorD_H*ones(n,1);

Y_Psi=yData-Psi;  %subtract the local mean
%Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*mean(yData(1:p,:)); %also generate initial conditions for the construction of the lagmatrix
Y_Psi(1:p,:)=yData(1:p,:)-ones(p,1)*(Psi(p+1,:)); %also generate initial conditions for the construction of the lagmatrix

% X_Psi = lagmatrix(Y_Psi,1:p); %create RHS of the VAR part                          
% X_Psi = X_Psi(p+1:end,:);     %remove the first p rows of RHS
X_Psi = lagx(Y_Psi,p-1);
X_Psi = X_Psi(1:end-1,:);
Y_Psi=Y_Psi(p+1:end,:);       %and do so for LHS

E=Y_Psi-X_Psi*B;              %VAR residuals
Escaled=E*A';                 %transform such that VAR residuals have variance Lambda

   for jj=1:T-p
   epst(:,:,jj)=E(jj,:)'; %generate period specific errors
   end
   
   scaling = ones(n,1); 
   Abelowdiag = cell(n,1);
   for kk=2:size(E,2)
       Abelowdiag{kk,1} = A(kk,1:kk-1)';
   end 


  %logHvarsOld = HvarsOld;
   logHvarsOld = log(HvarsOld);
   logHdraw = logHvarsOld(p+1:end,:);
%% draw the series lambda_i,t from their conditional posteriors, i=1,...,n and t=1,...,T

% consider variables in turn
   for jj=1:n
      % consider periods in turn
      for kk=p+1:T
      % a candidate value will be drawn from N(lambdabar,phibar)
      % the definitions of lambdabar and phibar varies with the period, thus define them first
         % if the period is the first period
         if kk==p+1
         %lambdabar=(gamma/(1+gamma^2))*((startMeanVector(jj,1))+logHvarsOld(kk+1,jj));
         lambdabar=(gamma*(h0(jj,1)+logHvarsOld(kk+1,jj)))/(1/kappa+gamma^2);
         phibar=phi_H(1,jj)/(1/kappa+gamma^2);
         %phibar=startVarVector(jj,1)+phi_H(1,jj)/(1/kappa+gamma^2);
         %if the period is the final period
         elseif kk==T
         lambdabar=gamma*logHdraw(end-1,jj);
         phibar=phi_H(1,jj);
         % if the period is any period in-between
         else
         lambdabar=(gamma/(1+gamma^2))*(logHdraw(kk-p-1,jj)+logHvarsOld(kk+1,jj));
         phibar=phi_H(1,jj)/(1+gamma^2);
         end
      % now draw the candidate
      cand=lambdabar+phibar^0.5*randn;

%       end 
      % compute the acceptance probability
      prob=mhprob2(jj,cand,logHvarsOld(kk,jj),scaling(jj,1),epst(:,1,kk-p),Abelowdiag{jj,1});
      % draw a uniform random number
      draw=rand;
         % keep the candidate if the draw value is lower than the prob
         if draw<=prob
         logHdraw(kk-p,jj)=cand;
%          else
%          logHdraw(kk-p,jj)=logHvarsOld(kk,jj);
%          % if not, just keep the former value
          end
      end
   end


G=speye(T-p)-sparse(diag(gamma*ones(T-p-1,1),-1));
% set the value for omega
omega=10;
% compute I_omega
I_o=sparse(diag([1/kappa;ones(T-p-1,1)]));
GIG=G'*I_o*G;
alpha0=0.01;
alphabar=T-p+alpha0;
delta0=0.01;   
   

% draw the parameters in turn
   for jj=1:n
   % estimate deltabar
   deltabar=logHdraw(1:end,jj)'*GIG*logHdraw(1:end,jj)+delta0;
   % draw the value phi_i
   phi_Hdraw(jj)=igrandn(alphabar/2,deltabar/2);
   end
   

   %% draw A
   Hvars=exp([zeros(n,p) logHdraw']');

   [Adraw]=sampleA_H(yData,Psi,B,Hvars,T,priorValues,dataValues);
   AdrawInv=Adraw\eye(n);
   
   %% sample the initial value
Kh0 = a0 + sparse(1:n,1:n,1./phi_Hdraw');
h0_hat = Kh0\(a0*b0 + log(Hvars(p+1,:)')./phi_Hdraw');
h0 = h0_hat + chol(Kh0,'lower')'\randn(n,1);   

   %% Construct H
Hdraw=zeros(n,n,T);


for t=1:T
    Hdraw(:,:,t)=AdrawInv*diag(Hvars(t,:))*AdrawInv';
end
 
HvarsDraw=Hvars;
   
   
   
   
