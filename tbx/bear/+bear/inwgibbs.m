function [beta_gibbs sigma_gibbs]=inwgibbs(It,Bu,beta0,omega0,S0,alpha0,X,Y,y,Bhat,n,T,q)



% function [beta_gibbs sigma_gibbs]=mxgibbs(It,Bu,beta0,omega0,S0,alpha0,X,Y,y,Bhat,n,T,q)
% performs the Gibbs algortihm 1.5.2 for the mixed prior, and returns draws from posterior distribution
% inputs:  - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide) 
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)
%          - matrix 'S0': prior scale matrix for sigma (defined in 1.4.11)
%          - integer 'alpha0': prior degrees of freedom for sigma (defined in 1.4.11)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - vector 'y': vectorised regressands for the VAR model (defined in 1.1.12)
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector 
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)



% preliminary tasks

% invert omega0, as it will be used repeatedly during step 4
invomega0=diag(1./diag(omega0));

% set initial values for B (step 2); use OLS estimates
B=Bhat;

% set the value of alphahat, defined in (1.5.16)
alphahat=T+alpha0;


% start iterations
for ii=1:It

% Step 3: at iteration ii, first draw sigma from IW, conditional on beta from previous iteration
% obtain first Shat, defined in (1.5.15)
Shat=(Y-X*B)'*(Y-X*B)+S0;
% Correct potential asymmetries due to rounding errors from Matlab
Shat=bear.nspd(Shat);

% next draw from IW(Shat,alphahat)
sigma=bear.iwdraw(Shat,alphahat);

% step 4: with sigma drawn, continue iteration ii by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
% first invert sigma
C=bear.trns(chol(bear.nspd(sigma),'Lower'));
invC=C\speye(n);
invsigma=invC*invC';

% then obtain the omegabar matrix
invomegabar=invomega0+kron(invsigma,X'*X);
C=chol(bear.nspd(invomegabar));
invC=C\speye(q);
omegabar=invC*invC';

% following, obtain betabar
betabar=omegabar*(invomega0*beta0+kron(invsigma,X')*y);

% draw from N(betabar,omegabar);
beta=betabar+chol(bear.nspd(omegabar),'lower')*randn(q,1);

% update matrix B with each draw
B=reshape(beta,size(B));

% record the values if the number of burn-in iterations is exceeded
if ii>Bu
% values of vector beta
beta_gibbs(:,ii-Bu)=beta;
% values of sigma (in vectorized form)
sigma_gibbs(:,ii-Bu)=sigma(:);
% if current iteration is still a burn iteration, do not record the result
else
end

% go for next iteration
end


