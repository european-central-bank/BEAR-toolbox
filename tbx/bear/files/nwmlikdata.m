function [logml log10ml ml]=nwmlik(X,n,T,k,phi0,S0,alpha0,Sbar,alphabar)



% function [logml log10ml ml]=nwmlik(X,n,T,k,phi0,S0,alpha0,Sbar,alphabar)
% computes the marginal likelihood for a normal-Wishart prior, by implementing algorithm XXX
% inputs:  - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - matrix 'phi0': prior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.7)
%          - matrix 'S0': prior scale matrix for sigma (defined in 1.4.11)
%          - integer 'alpha0': prior degrees of freedom for sigma (defined in 1.4.11)
%          - matrix 'Sbar': posterior scale matrix for sigma (defined in 1.4.19)
%          - integer 'alphabar': posterior degrees of freedom for sigma (defined in 1.4.18)
% outputs: - scalar 'logml': base e log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'log10ml': base 10 log of the marginal likelihood (defined in 1.2.9)
%          - scalar 'ml': marginal likelihood (defined in 1.2.9)




% compute the constant part of the marginal likelihood
temp1=(-n*T/2)*log(pi)+mgamma(alphabar/2,n)-mgamma(alpha0/2,n);

% compute the second determinant part
% because S0 is diagonal, simply compute its determinant as the product of its diagonal terms
temp2=(-T/2)*log(prod(diag(S0)));

% compute the first determinant part
% create the square root matrix of phi0
% because phi0 is diagonal, this is simply the square root of the diagonal terms of phi0
Fphi=spdiags(diag(phi0).^0.5,0,k,k);
% compute the product
product=Fphi'*X'*X*Fphi;
% compute the eigenvalues of the product
eigenvalues=eig(product);
% now compute the full determinant term
temp3=(-n/2)*log(prod(diag(eye(k)+diag(eigenvalues))));

% compute the third determinant part
% create the square root matrix of inv(S0)
invS0=spdiags(1./diag(S0),0,n,n);
Fs=spdiags(diag(invS0).^0.5,0,n,n);
% compute the summation
summ=Fs'*(Sbar-S0)*Fs;
% compute the eigenvalues of the summation
eigenvalues=eig(summ);
% now compute the full determinant term
temp4=(-alphabar/2)*log(prod(diag(eye(n)+diag(eigenvalues))));

% compute the marginal likelihood
logml=real(temp1+temp2+temp3+temp4);
log10ml=logml/log(10);
ml=exp(logml);





