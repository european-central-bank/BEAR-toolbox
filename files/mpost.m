function [betabar omegabar]=mpost(beta0,omega0,sigma,X,y,q,n)



% function[betabar omegabar]=mpost(beta0,omega0,sigma,X,y,q,n)
% compute the posterior parameters for a Minnesota prior
% inputs:  - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)
%          - matrix 'sigma': 'true' variance-covariance matrix of VAR residuals, for the original Minnesota prior
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - vector 'y': vectorised regressands for the VAR model (defined in 1.1.12)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - vector 'betabar': posterior mean vector (defined in 1.3.18)
%          - matrix 'omegabar': posterior covariance matrix for the VAR coefficients (defined in 1.3.17)



% first compute all the inverses required for the calculation of the posterior
% do not use the inv function as it is numerically terrible

% compute the inverse of omega0
% as it is a diagonal matrix, a numerically efficient way to invert it is simply to take the inverse of each diagonal element
invomega0=diag(1./diag(omega0));

% compute the inverse of sigma
% use a numerically efficient method: first compute the (upper) choleski factor of sigma
% then compute the inverse of this choleski factor using the efficient mldivide operator
% finally obtain the inverse of sigma by taking the product of the inverse just obtained with its transpose
C=chol(nspd(sigma));
invC=C\speye(n);
invsigma=invC*invC';


% compute omegabar, the posterior variance-covariance matrix for beta, using (1.3.17)
invomegabar=invomega0+kron(invsigma,X'*X);
C=chol(nspd(invomegabar));
invC=C\speye(q);
omegabar=invC*invC';


% compute betabar, the posterior mean vector for beta, using (1.3.18)
betabar=omegabar*(invomega0*beta0+kron(invsigma,X')*y);



