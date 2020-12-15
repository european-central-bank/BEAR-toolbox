function [beta_median beta_std beta_lbound beta_ubound sigma_median]=ndestimates(beta_gibbs,sigma_gibbs,cband,q,n,k)



% function [beta_median beta_std beta_lbound beta_ubound sigma_median]=ndestimates(beta_gibbs,sigma_gibbs,cband,q,n,k)
% estimates the posterior mean, standard deviation and confidence interval for the VAR coefficients (normal diffuse prior)
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - scalar 'cband': confidence level for VAR coefficients
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - vector 'beta_median': median value of the posterior distribution of beta 
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)



% compute the mean, standard deviation, and credibility intervals for the posterior distribution of beta
for ii=1:q
beta_median(ii,1)=[quantile(beta_gibbs(ii,:),0.5)];
beta_std(ii,1)=std(beta_gibbs(ii,:));
beta_lbound(ii,:)=[quantile(beta_gibbs(ii,:),(1-cband)/2)];
beta_ubound(ii,:)=[quantile(beta_gibbs(ii,:),1-(1-cband)/2)];
end


% compute the mean for the posterior distribution of sigma
for ii=1:n^2
sigma_median(ii,1)=[quantile(sigma_gibbs(ii,:),0.5)];
end
sigma_median=reshape(sigma_median,n,n);












