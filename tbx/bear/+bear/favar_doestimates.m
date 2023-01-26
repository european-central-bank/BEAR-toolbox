function [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=favar_doestimates(favar)

% simply the median of the estimates computed in the gibbs sampler
beta_median=quantile(favar.beta_median_gibbs,0.5,3);
B_median=quantile(favar.B_median_gibbs,0.5,3);
beta_std=quantile(favar.beta_std_gibbs,0.5,3);
beta_lbound=quantile(favar.beta_lbound_gibbs,0.5,3);
beta_ubound=quantile(favar.beta_ubound_gibbs,0.5,3);
sigma_median=quantile(favar.sigma_median_gibbs,0.5,3);

