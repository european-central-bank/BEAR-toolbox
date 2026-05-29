function [beta_median beta_std beta_lbound beta_ubound sigma_median]=olsestimates(betahat,sigmahat,X,k,q,cband)



% function [beta_median beta_std beta_lbound beta_ubound sigma_median]=olsestimates(betahat,sigmahat,X,k,q,cband)
% estimates the posterior mean, standard deviation and confidence interval for the VAR coefficients of an OLS VAR model
% inputs:  - vector 'betahat': OLS VAR coefficientsm in vectorised form (defined in 1.1.15) 
%          - matrix 'sigmahat': OLS VAR variance-covariance matrix of residuals (defined in 1.1.10)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - scalar 'cband': confidence level for VAR coefficients
% outputs: - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)



% compute the point estimate of beta
beta_median=betahat;
% compute estimates for the variance of each coefficient
% first obtain omeagahat, the (OLS) variance-covariance matrix for betahat, from (a.9.1)
omegahat=kron(sigmahat,(X'*X)\speye(k));
% consider only the diagonal (variance terms), and take the square root of each element
beta_std=diag(omegahat).^0.5;
% build the confidence intervals
for ii=1:q
beta_lbound(ii,:)=norminv((1-cband)/2,beta_median(ii,1),beta_std(ii,1));
beta_ubound(ii,:)=norminv(1-(1-cband)/2,beta_median(ii,1),beta_std(ii,1));
end


sigma_median=sigmahat;
