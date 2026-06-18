function [beta_median B_median beta_std beta_lbound beta_ubound sigma_median]=doestimates(betacap,phicap,Scap,alphacap,alphatop,n,k,cband)





% compute the median of beta, using (a.2.17), and the fact that for a student distribution, the median is just the mean
beta_median=betacap;
B_median=reshape(beta_median,k,n);

% now compute the variance of beta
% define the scale matrix of vec(B)
scale=kron(Scap,phicap);
% obtain the variance-covariance matrix for beta as (1/(alphatop-2))*scale
varcov=(1/(alphatop-2))*scale;
% keep only the diagonal (variance terms)
beta_var=diag(varcov);
% compute standard deviation
beta_std=beta_var.^(1/2);


% obtain confidence intervals for beta, using (a.2.19)-(a.2.20)
% first obtain the individual scale parameter of each coefficient for its variance
scale=((alphatop-2)/alphatop)^0.5*beta_std;
beta_lbound=[betacap+tinv((1-cband)/2,alphatop)*scale];
beta_ubound=[betacap+tinv(1-(1-cband)/2,alphatop)*scale];


% compute the mean of sigma, using (a.2.13) (it is here abusively called median for consistency with the rest of the code, but it is actually only the mean that can be computed for an inverse Wishart)
sigma_median=(1/(alphacap-n-1))*Scap;

