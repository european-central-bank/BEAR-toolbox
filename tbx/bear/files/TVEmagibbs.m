function [beta_gibbs, sigma_gibbs, theta_gibbs, ss_record,indH,beta_theta_gibbs]=TVEmagibbs(data_endo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,n,T,k1,q1,p,regimeperiods,names,TVEH)


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



% this function implements algorithm...


% preliminary tasks

% take the alternative exogenous regime
if isempty(regimeperiods)
    data_exo=[ones(size(data_endo,1),1)];
else
data_exo=[ones(size(data_endo,1),1) zeros(size(data_endo,1),1)];
data_exo(find(strcmp(names(2:end,1),regimeperiods(1))):find(strcmp(names(2:end,1),regimeperiods(2))),2)=1;
data_exo(find(strcmp(names(2:end,1),regimeperiods(1))):find(strcmp(names(2:end,1),regimeperiods(2))),1)=0;
end

indH=zeros(T+p,1);
for iR=1:size(data_exo,2)
    indH(data_exo(:,iR)==1)=iR;
end

% create the cell that will store the records for the steady-state
ss_record=cell(n,1); %change

% invert omega0
invomega0=diag(1./diag(omega0));

% invert lambda0
invlambda0=lambda0\eye(length(lambda0));

% step 2: set initial values
% set initial values for B, beta and sigma; as no OLS estimates are available, simply set the value as zeros for B and beta, and identity for sigma
B=zeros(k1,n);

% define the initial value for the inverse of sigma: beacause sigma is identity, this is also identity
invsigma=eye(n);

% preallocate space for the matrix with the equilibrium values
eq=zeros(T+p,n);

q2=length(psi0);

hbar = parfor_progressbar(It,'Progress of the Gibbs sampler');  %create the progress bar


% start iterations
for ii=1:It

hbar.iterate(1);   % update progress by one iteration


% step 3: at iteration ii, draw psi from N, conditional on beta and sigma
% obtain the lambdabar matrix
Ybar=Y-X*B;
Ypsi=vec(Ybar');

t=1;
Fsimple=TVEH(:,:,indH(t+p),t+p);
for k=2:p+1
    Fsimple=Fsimple-B((k-2)*n+1:(k-1)*n,:)'*TVEH(:,:,indH(t+p-(k-1)),t+p-(k-1));
end

for t=2:T
    Ftemp=TVEH(:,:,indH(t+p),t+p);
    for k=2:p+1
        Ftemp=Ftemp-B((k-2)*n+1:(k-1)*n,:)'*TVEH(:,:,indH(t+p-(k-1)),t+p-(k-1));
    end
    Fsimple=cat(1,Fsimple,Ftemp);
end

invOmega=kron(eye(T),invsigma);


CT=(invlambda0+Fsimple'*invOmega*Fsimple)\eye(length(lambda0));
mT=CT*(Fsimple'*invOmega*Ypsi++invlambda0*psi0);

% draw from N(psibar,lambdabar);
theta=mT+chol(nspd(CT),'lower')*randn(q2,1);

% recover equilibrium values from psi
for it=1:T+p
    eq(it,:)=(squeeze(TVEH(:,:,indH(it),it))*theta)'; % compute the equilibrium values given theta
end

% step 4: now that psi/F has been drawn, it is possible to generate Yhat, Xhat and yhat
temp2=data_endo-eq;
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

   % record the values if the number of burn-in iterations is exceeded
   if ii>Bu
   % record the value of beta
   beta_gibbs(:,ii-Bu)=beta;
   % record the value of sigma (in vectorized form)
   sigma_gibbs(:,ii-Bu)=sigma(:);
   
   % compute and record the steady-state 
   ss=eq;
   % trim p initial conditions to be consistent with the sample
   ss=ss(p+1:end,:);
      % then record in the corresponding cell
      for jj=1:n
      ss_record{jj,1}(ii-Bu,:)=ss(:,jj)';
      end
   % finally, record theta
   theta_gibbs(:,ii-Bu)=theta;
   
   beta_theta_gibbs(:,ii-Bu)=[beta;theta];
   % if current iteration is still a burn iteration, do not record the result
   else
   end

% step 7: go for next iteration
end

close(hbar);   %close progress bar

