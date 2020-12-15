function [logml log10ml ml]=inwmlik(Y,X,n,k,q,T,beta0,omega0,S0,alpha0,beta_median,sigma_median,beta_gibbs,It,Bu,scoeff,iobs)






% function [logml log10ml ml]=mxmlik(Y,X,n,k,q,T,beta0,omega0,S0,alpha0,beta_median,sigma_median,beta_gibbs,Bhat,It,Bu)
% computes the marginal likelihood of the model for a mixed prior by implementing algorithm 1.8.1
% inputs:  - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)
%          - matrix 'S0': prior scale matrix for sigma (defined in 1.4.11)
%          - integer 'alpha0': prior degrees of freedom for sigma (defined in 1.4.11)
%          - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
% outputs: - scalar 'logml': base e log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'log10ml': base 10 log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'ml': marginal likelihood (defined in 1.2.9)



% first check if there are dummy extensions
if (scoeff==1 || iobs==1)
% if yes, do not compute the marginal likelihood: it has proven too numerically unstable with these extensions
logml=nan;
log10ml=nan;
ml=nan;


% if no dummy observations were added
elseif (scoeff==0 && iobs==0)
% then do compute the marginal likelihood


% preliminary work: obtain elements required later in the code
% reshape beta to obtain B
B_median=reshape(beta_median,k,n);
% obtain the inverse of sigma
C=trns(chol(nspd(sigma_median),'Lower'));
invC=C\speye(n);
invsigmamedian=invC*invC';
% obtain the residual sum of squares
res=(Y-X*B_median)'*(Y-X*B_median);
% create the inverse of omega0
% because omega0 is diagonal, this is simply the inverse of each diagonal term of omega0
invomega0=diag(1./diag(omega0));
% create the square root matrix of omega0
% because omega0 is diagonal, this is simply the square root of the diagonal terms of omega0
Fomega=spdiags(diag(omega0).^0.5,0,q,q);
% finally, compute the constant terms for the Gibbs sampler part
alphahat=T+alpha0;

% step 1: compute the constant terms
temp1=-n*T/2*log(2*pi)-alpha0*n/2*log(2)-mgamma(alpha0/2,n);

% step 2: determinants on S0 and sigmabar
temp2=alpha0/2*log(det(S0))-(T+alpha0+n+1)/2*log(det(sigma_median));

% step 3: trace term for data density
temp3=-1/2*trace(invsigmamedian*(res+S0));

% step 4: determinant term
% first, compute the product
product=Fomega'*kron(eye(n),X')*kron(invsigmamedian,X)*Fomega;
% compute the eigenvalues of the product
eigenvalues=eig(product);
% now compute the full determinant term
temp4=-1/2*log(prod(diag(eye(q)+diag(eigenvalues))));

% step 5: final density term
temp5=-1/2*(beta_median-beta0)'*invomega0*(beta_median-beta0);

 % step 6: obtain posterior density for sigma
   % loop over Gibbs sampler results
   for ii=1:It-Bu
   % obtain Shat
   B=reshape(beta_gibbs(:,ii),k,n);
   Shat=(Y-X*B)'*(Y-X*B)+S0;
   % compute the density
   [~,val]=iwdensity(sigma_median,Shat,alphahat,n);
   % record the value
   values(ii,1)=val;
   end
% compute the mean
meanval=sum(values)/(It-Bu);
temp6=-log(meanval);

% step 7: compute the marginal likelihood from (1.8.5)
logml=real(temp1+temp2+temp3+temp4+temp5+temp6);
% convert into log10
log10ml=logml/log(10);
ml=exp(logml);

end



