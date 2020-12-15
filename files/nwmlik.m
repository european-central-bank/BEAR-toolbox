function [logml log10ml ml]=nwmlik(X,Xdum,Ydum,n,T,Tdum,k,B0,phi0,S0,alpha0,Sbar,alphabar,scoeff,iobs)



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





% first compute the marginal likelihood for the data set (possibly augmented with dummy)
[logml log10ml ml]=nwmlikdata(X,n,T,k,phi0,S0,alpha0,Sbar,alphabar);


% if there are dummy observations in the data set
if (scoeff==1 || iobs==1)
% then compute posterior elements for the dummy observations
[~,~,~,Sbardum,alphabardum,~]=nwpost(B0,phi0,S0,alpha0,Xdum,Ydum,n,Tdum,k);
% and use those elements to compute the marginal likelihood for the dummy observations only
[logmldum log10mldum mldum]=nwmlikdata(Xdum,n,Tdum,k,phi0,S0,alpha0,Sbardum,alphabardum);
% eventually obtain the marginal likelihood for actual data by division
logml=logml-logmldum;
log10ml=log10ml-log10mldum;
ml=ml/mldum;
end









