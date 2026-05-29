function [beta_median beta_std beta_lbound beta_ubound psi_median psi_std psi_lbound psi_ubound sigma_median]=maestimates(beta_gibbs,psi_gibbs,sigma_gibbs,cband,q1,q2,n)



% function [beta_median beta_std beta_lbound beta_ubound psi_median psi_std psi_lbound psi_ubound sigma_median]=maestimates(beta_gibbs,psi_gibbs,sigma_gibbs,cband,q1,q2,n)
% estimates the posterior mean, standard deviation and confidence interval for the VAR coefficients of a mean-adjusted BVAR model
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector 
%          - matrix 'psi_gibbs': record of the gibbs sampler draws for the psi vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - scalar 'cband': confidence level for VAR coefficients
%          - integer 'q1': total number of endogenous coefficients to estimate in the MABVAR model (defined p 77 of technical guide)
%          - integer 'q2': total number of exogenous coefficients to estimate in the MABVAR model (defined p 77 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
% outputs: - vector 'beta_median': median value of the posterior distribution of beta 
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'psi_median': median value of the posterior distribution of psi
%          - vector 'psi_std': standard deviation of the posterior distribution of psi
%          - vector 'psi_lbound': lower bound of the credibility interval of psi
%          - vector 'psi_ubound': upper bound of the credibility interval of psi
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)



% compute the median, standard deviation, and credibility intervals for the posterior distribution of beta
for ii=1:q1
beta_median(ii,1)=[quantile(beta_gibbs(ii,:),0.5)];
beta_std(ii,1)=std(beta_gibbs(ii,:));
beta_lbound(ii,:)=[quantile(beta_gibbs(ii,:),(1-cband)/2)];
beta_ubound(ii,:)=[quantile(beta_gibbs(ii,:),1-(1-cband)/2)];
end

% compute the median, standard deviation, and credibility intervals for the posterior distribution of psi
for ii=1:q2
psi_median(ii,1)=[quantile(psi_gibbs(ii,:),0.5)];
psi_std(ii,1)=std(psi_gibbs(ii,:));
psi_lbound(ii,:)=[quantile(psi_gibbs(ii,:),(1-cband)/2)];
psi_ubound(ii,:)=[quantile(psi_gibbs(ii,:),1-(1-cband)/2)];
end

% compute the median for the posterior distribution of sigma
for ii=1:n^2
sigma_median(ii,1)=[quantile(sigma_gibbs(ii,:),0.5)];
end
sigma_median=reshape(sigma_median,n,n);













