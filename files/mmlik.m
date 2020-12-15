function [logml log10ml ml]=mmlik(X,Xdum,y,ydum,n,T,Tdum,q,sigma,beta0,omega0,betabar,scoeff,iobs)


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




% first compute the marginal likelihood for the data set (possibly augmented with dummy)
[logml log10ml ml]=mmlikdata(X,y,n,T,q,sigma,beta0,omega0,betabar);

% if there are dummy observations in the data set
if (scoeff==1 || iobs==1)
% then compute posterior elements for the dummy observations
[betabardum,~]=mpost(beta0,omega0,sigma,Xdum,ydum,q,n);
% and use those elements to compute the marginal likelihood for the dummy observations only
[logmldum log10mldum mldum]=mmlikdata(Xdum,ydum,n,Tdum,q,sigma,beta0,omega0,betabardum);
% eventually obtain the marginal likelihood for actual data by division
logml=logml-logmldum;
log10ml=log10ml-log10mldum;
ml=ml/mldum;
end









