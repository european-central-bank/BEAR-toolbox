function [Bbar betabar phibar Sbar alphabar alphatilde]=nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k)



% function [Bbar betabar phibar Sbar alphabar alphatilde]=nwpost(B0,beta0,phi0,S0,alpha0,Bhat,X,Y,n,T,k)
% compute the posterior parameters for a normal-Wishart prior
% inputs:  - matrix 'B0': the non-vectorised form of beta0
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'phi0': prior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.7)
%          - matrix 'S0': prior scale matrix for sigma (defined in 1.4.11)
%          - integer 'alpha0': prior degrees of freedom for sigma (defined in 1.4.11)
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'Bbar': posterior matrix of VAR coefficients for the normal-Wishart prior (defined in 1.4.17)
%          - vector 'betabar': posterior mean vector (defined in 1.3.18)
%          - matrix 'phibar':posterior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.16)
%          - matrix 'Sbar': posterior scale matrix for sigma (defined in 1.4.19)
%          - integer 'alphabar': posterior degrees of freedom for sigma (defined in 1.4.18)
%          - integer 'alphatilde': degrees of freedom of the matrix student distribution (defined in 1.4.23)



% first compute all the inverses required for the calculation of the posterior

% compute the inverse of phi0
% as it is a diagonal matrix, simply to take the inverse of each diagonal element
invphi0=diag(1./diag(phi0));

% compute phibar, defined in (1.4.16)
invphibar=invphi0+X'*X;
C=trns(chol(nspd(invphibar),'Lower'));
invC=C\speye(k);
phibar=invC*invC';

% compute Bbar, defined in (1.4.17)
Bbar=phibar*(invphi0*B0+X'*Y);

% vectorise to obtain betabar, also defined in (1.4.17)
betabar=Bbar(:);

% obtain alphabar, defined in (1.4.18)
alphabar=T+alpha0;

% obtain alphatilde, defined in (1.4.24)
alphatilde=T+alpha0-n+1;

% obtain Sbar, defined in (1.4.19)
Sbar=Y'*Y+S0+B0'*invphi0*B0-Bbar'*invphibar*Bbar;
% stabilise Sbar to avoid numerical errors
Sbar=nspd(Sbar);








