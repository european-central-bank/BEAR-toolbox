function [beta_median B_median beta_std beta_lbound beta_ubound sigma_median]=nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband)



% [beta_median B_median beta_std beta_lbound beta_ubound sigma_median]=nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband)
% % estimates the posterior mean, standard deviation and confidence interval for the VAR coefficients (normal Wishart prior)
% inputs:  - vector 'betabar': posterior mean vector (defined in 1.3.18)
%          - matrix 'phibar':posterior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.16)
%          - matrix 'Sbar': posterior scale matrix for sigma (defined in 1.4.19)
%          - integer 'alphabar': posterior degrees of freedom for sigma (defined in 1.4.18)
%          - integer 'alphatilde': degrees of freedom of the matrix student distribution (defined in 1.4.23)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - scalar 'cband': confidence level for VAR coefficients
% outputs: - vector 'beta_median': median value of the posterior distribution of beta
%          - vector 'beta_median': median value of the posterior distribution of beta
%          - matrix 'B_median': median value of the posterior distribution of B
%          - vector 'beta_std': standard deviation of the posterior distribution of beta
%          - vector 'beta_lbound': lower bound of the credibility interval of beta
%          - vector 'beta_ubound': upper bound of the credibility interval of beta
%          - vector 'sigma_median': median value of the posterior distribution of sigma (vectorised)



% compute the median of beta, using (a.2.17), and the fact that for a student distribution, the median is just the mean
beta_median=betabar;
B_median=reshape(betabar,k,n);

% now compute the variance of beta, using (a.2.17)
% define the scale matrix of vec(B)
scale=kron(Sbar,phibar);
% obtain the variance-covariance matrix for beta as (1/(alphatilde-2))*scale
varcov=(1/(alphatilde-2))*scale;
% keep only the diagonal (variance terms)
beta_var=diag(varcov);
% compute standard deviation
beta_std=beta_var.^(1/2);


% obtain confidence intervals for beta, using (a.2.19)-(a.2.20)
% first obtain the individual scale parameter of each coefficient for its variance
scale=((alphatilde-2)/alphatilde)^0.5*beta_std;
beta_lbound=[betabar+tinv((1-cband)/2,alphatilde)*scale];
beta_ubound=[betabar+tinv(1-(1-cband)/2,alphatilde)*scale];


% compute the mean of sigma, using (a.2.13) (it is here abusively called median for consistency with the rest of the code, but it is actually only the mean that can be computed for an inverse Wishart)
sigma_median=(1/(alphabar-n-1))*Sbar;

