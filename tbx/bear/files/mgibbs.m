function [beta_gibbs sigma_gibbs]=mgibbs(It,Bu,betabar,omegabar,sigma,q)



% function [beta_gibbs sigma_gibbs]=mgibbs(It,Bu,betabar,omegabar,sigma,q)
% performs the Gibbs algorithm 2.1.2 for the Minnesota prior, and returns draws from posterior distribution
% inputs:  - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - vector 'betabar': posterior mean vector (defined in 1.3.18)
%          - matrix 'omegabar': posterior covariance matrix for the VAR coefficients (defined in 1.3.17)
%          - matrix 'sigma': 'true' variance-covariance matrix of VAR residuals, for the original Minnesota prior
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)



% start iterations
for ii=1:(It-Bu)
% draw a random vector beta from N(betabar,sigmabar) (step 3 of the algorithm)
beta=betabar+chol(nspd(omegabar),'lower')*randn(q,1);

% record values before starting next iteration
beta_gibbs(:,ii)=beta;
% go for next iteration
end

% record the values for the variance-covariance matrix sigma
% vectorize sigma and record it (it-Bu) times
sigma_gibbs=repmat(sigma(:),1,It-Bu);
