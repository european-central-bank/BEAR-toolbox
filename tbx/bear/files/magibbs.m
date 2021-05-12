function [beta_gibbs psi_gibbs sigma_gibbs delta_gibbs ss_record]=magibbs(data_endo,data_exo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,Z,n,m,T,k1,k3,q1,q2,q3,p,regimeperiods,names)



% function [beta_gibbs psi_gibbs sigma_gibbs ss_record delta_gibbs]=magibbs(data_endo,data_exo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,Z,n,m,T,k1,k3,q1,q2,q3,p)
% performs the Gibbs algortihm 3.5.1 for a MABVAR model, and returns draws from posterior distribution
% inputs:  - matrix 'data_endo': the matrix storing the endogenous time series data used to estimate the model
%          - matrix 'data_exo': the matrix storing the exogenous time series data used to estimate the model 
%          - integer 'It': the total number of iterations run by the Gibbs sampler
%          - integer 'Bu': the number of initial iterations discared as burn-in sample
%          - vector 'beta0': the vector containing the mean of the prior distribution for beta, defined in (3.5.17)
%          - matrix 'omega0': the variance-covariance matrix for the prior distribution of beta, defined in (3.5.17)
%          - vector 'psi0': the vector containing the mean of the prior distribution for psi, defined in (3.5.19)
%          - matrix 'lambda0': the variance-covariance matrix for the prior distribution of psi, defined in (3.5.19)
%          - matrix 'Y': the matrix of endogenous variables, defined in (3.5.10)
%          - matrix 'X': the matrix of endogenous regressors, defined in (3.5.10)
%          - matrix 'Z': the matrix of exogenous regressors, defined in (3.5.10)
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'T': the sample size, i.e. the number of time periods used to estimate the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
%          - integer 'k3': the number of coefficients related to the exogenous variables for each equation, in the reformulated model (3.5.5)
%          - integer 'q1': the total number of VAR coefficients related to the endogenous variables
%          - integer 'q2': the total number of VAR coefficients related to the exogenous variables
%          - integer 'q3': the total number of VAR coefficients related to the exogenous variables, in the reformulated model (3.5.5)
%          - integer 'p': the number of lags in the model
% outputs: - matrix 'beta_gibbs': the matrix recording the post-burn draws of beta
%          - matrix 'psi_gibbs': the matrix recording the post-burn draws of psi
%          - matrix 'sigma_gibbs': the matrix recording the post-burn draws of sigma
%          - matrix 'delta_gibbs': the matrix recording the post-burn draws of delta
%          - cell 'ss_record': the cell storing the post-burn steady-state values



% this function implements algorithm 3.5.1


% preliminary tasks

% take the alternative exogenous regime
if isempty(regimeperiods);
    data_exo=[ones(size(data_endo,1),1)];
else
data_exo=[ones(size(data_endo,1),1) zeros(size(data_endo,1),1)];
data_exo(find(strcmp(names(2:end,1),regimeperiods(1))):find(strcmp(names(2:end,1),regimeperiods(2))),2)=1;
end
% create the cell that will store the records for the steady-state
ss_record=cell(n,1);

% generate the matrix of exogenous, as it will be used to build Yhat in (3.5.20)
%temp1=[ones(size(data_endo,1),1) data_exo];
temp1=data_exo;
% invert omega0
invomega0=diag(1./diag(omega0));

% invert lambda0
invlambda0=diag(1./diag(lambda0));


% step 2: set initial values
% set initial values for B, beta and sigma; as no OLS estimates are available, simply set the value as zeros for B and beta, and identity for sigma
B=zeros(k1,n);
beta=zeros(q1,1);
sigma=eye(n);

% define the initial value for U, using the initial value for B
U=eye(q2);
   for jj=1:p
   U=[U;kron(eye(m),B((jj-1)*n+1:jj*n,:)')];
   end

% define the initial value for the inverse of sigma: beacause sigma is identity, this is also identity
invsigma=eye(n);



% start iterations
for ii=1:It



% step 3: at iteration ii, draw psi from N, conditional on beta and sigma
% obtain the lambdabar matrix
invlambdabar=invlambda0+U'*kron(Z'*Z,invsigma)*U;
C=trns(chol(nspd(invlambdabar),'Lower'));
invC=C\speye(q2);
lambdabar=invC*invC';
% compute the psibar vector
psibar=lambdabar*(invlambda0*psi0+U'*reshape(invsigma*(Y-X*B)'*Z,q3,1));
% draw from N(psibar,lambdabar);
psi=psibar+chol(nspd(lambdabar),'lower')*randn(q2,1);
% recover F from psi
F=reshape(psi,n,m);


% step 4: now that psi/F has been drawn, it is possible to generate Yhat, Xhat and yhat
temp2=data_endo-temp1*F';
temp3=lagx(temp2,p);
Yhat=temp3(:,1:n);
yhat=Yhat(:);
Xhat=temp3(:,n+1:end);


% step 5: next, at iteration ii, draw sigma from IW, conditional on most recent draw for psi and beta
% obtain first Stilde
Stilde=(Yhat-Xhat*B)'*(Yhat-Xhat*B);
% next draw from IW(Stilde,T)
sigma=iwdraw(Stilde,T);
% invert sigma
C=trns(chol(nspd(sigma),'Lower'));
invC=C\speye(n);
invsigma=invC*invC';



% step 6: finally, at iteration ii, draw beta from a N, conditional on most recent draw for psi and sigma
% first obtain the omegabar matrix
invomegabar=invomega0+kron(invsigma,Xhat'*Xhat);
C=trns(chol(nspd(invomegabar),'Lower'));
invC=C\speye(q1);
omegabar=invC*invC';
% following, obtain betabar
betabar=omegabar*(invomega0*beta0+kron(invsigma,Xhat')*yhat);
% draw from N(betabar,omegabar);
beta=betabar+chol(nspd(omegabar),'lower')*randn(q1,1);
% reshape to obtain B
B=reshape(beta,k1,n);
% update U, using the draw obtained for B
U=eye(n*m);
   for jj=1:p
   U=[U;kron(eye(m),B((jj-1)*n+1:jj*n,:)')];
   end


   % record the values if the number of burn-in iterations is exceeded
   if ii>Bu
   % record the value of beta
   beta_gibbs(:,ii-Bu)=beta;
   % record the value of sigma (in vectorized form)
   sigma_gibbs(:,ii-Bu)=sigma(:);
   % record the value of psi
   psi_gibbs(:,ii-Bu)=psi;
   % also, compute and record the steady-state 
   ss=temp1*F';
   % trim p initial conditions to be consistent with the sample
   ss=ss(p+1:end,:);
      % then record in the corresponding cell
      for jj=1:n
      ss_record{jj,1}(ii-Bu,:)=ss(:,jj)';
      end
   % finally, record delta, the vectorised version of Delta, as it will be used in further parts of the code
   vecDeltaT=U*psi;
   DeltaT=reshape(vecDeltaT,n,k3);
   %vectorise and record
   delta_gibbs(:,ii-Bu)=reshape(DeltaT',q3,1);
   % if current iteration is still a burn iteration, do not record the result
   else
   end

% step 7: go for next iteration
end


