function [beta_median beta_std beta_lbound beta_ubound sigma_median]=mestimates(betabar,omegabar,sigma,q,cband)


% function [beta_mean beta_std beta_lbound beta_ubound sigma_vec]=mestimates(betabar,omegabar,sigma,q,cband)
% estimates the posterior mean, standard deviation and confidence interval for the VAR coefficients (Minnesota prior)
% inputs:  - vector 'betabar': the vector containing the posterior mean for beta, defined in (1.3.18)
%          - matrix 'omegabar': the matrix containing the posterior variance for beta, defined in (1.3.17)
%          - matrix 'sigma': the covariance matrix of the VAR residuals, defined in (1.1.3), assumed to be fixed and known
%          - integer 'q': the total number of VAR coefficients to be estimated
%          - scalar 'cband': size of confidence band for the VAR coefficients
% outputs: - vector 'beta_median': a vector containing the posterior median values for beta
%          - vector 'beta_std': a vector containing the posterior standard deviations for beta
%          - vector 'beta_ubound': a vector containing the upper bound of the credibility interval for beta
%          - vector 'beta_lbound': a vector containing the lower bound of the credibility interval for beta
%          - matrix 'sigma_median':a matrix containing the posterior median values for sigma





% compute the mean, variance, and credibility intervals for the posterior distribution of beta
% them mean and variance obtain from (a.2.3)
for ii=1:q
beta_median(ii,1)=betabar(ii,1);
beta_std(ii,1)=omegabar(ii,ii)^0.5;
beta_lbound(ii,:)=norminv((1-cband)/2,beta_median(ii,1),beta_std(ii,1));
beta_ubound(ii,:)=norminv((1-(1-cband)/2),beta_median(ii,1),beta_std(ii,1));
end


% compute the results for sigma
% write sigma resulting from the prior in vectorized form
sigma_median=sigma;










