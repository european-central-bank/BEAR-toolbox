function [logml log10ml ml]=mmlikdata(X,y,n,T,q,sigma,beta0,omega0,betabar)


% function [logml log10ml ml]=mmlik(X,y,n,T,q,sigma,omega0,beta0,betabar)
% computes the marginal likelihood for a Minesota prior, by implementing algorithm XXX
% inputs:  - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - vector 'y': vectorised regressands for the VAR model (defined in 1.1.12)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - matrix 'sigma': 'true' variance-covariance matrix of VAR residuals, for the original Minnesota prior
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)
%          - vector 'betabar': posterior mean vector (defined in 1.3.18)
% outputs: - scalar 'logml': base e log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'log10ml': base 10 log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'ml': marginal likelihood (defined in 1.2.9)



% compute the constant part of the marginal likelihood
temp1=(-n*T/2)*log(2*pi)+(-T/2)*log(det(sigma));

% compute the log determinant part
% create the square root matrix of omega0
% because omega0 is diagonal, this is simply the square root of the diagonal terms of omega0
Fomega=spdiags(diag(omega0).^0.5,0,q,q);
% compute the inverse of sigma
C=chol(nspd(sigma));
invC=C\speye(n);
invsigma=invC*invC';
% compute the product
product=Fomega'*kron(invsigma,X'*X)*Fomega;
% compute the eigenvalues of the product
if n == 1
    eigenvalues=eig(full(product));
else
    eigenvalues=eig(product);
end
% now compute the full determinant term
temp2=(-1/2)*log(prod(diag(eye(q)+diag(eigenvalues))));

% compute the final term
% first compute the inverse of omega0, which is a diagonal matrix (hence simply invert element wise the diagonal terms)
invomega0=spdiags(1./diag(omega0),0,q,q);
% compute the inverse of omegabar
invomegabar=invomega0+kron(invsigma,X'*X);
% now compute the whole matrix sum
summ=beta0'*invomega0*beta0-betabar'*invomegabar*betabar+y'*kron(invsigma,speye(T))*y;
% finally, compute the whole exponential term
temp3=-0.5*summ;

% compute the marginal likelihood
logml=real(temp1+temp2+temp3);
log10ml=logml/log(10);
ml=exp(logml);









