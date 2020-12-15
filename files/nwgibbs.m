function [beta_gibbs sigma_gibbs]=nwgibbs(It,Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k)



% function [beta_gibbs sigma_gibbs]=nwgibbs(It,Bu,Bbar,phibar,alphatilde,Sbar,alphabar,n,k)
% performs the Gibbs algortihm 2.1.3 for the normal-Wishart prior, and returns draws from posterior distribution
% inputs:  - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide) 
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix 'Bbar': posterior matrix of VAR coefficients for the normal-Wishart prior (defined in 1.4.17)
%          - matrix 'phibar':posterior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.16)
%          - matrix 'Sbar': posterior scale matrix for sigma (defined in 1.4.19)
%          - integer 'alphabar': posterior degrees of freedom for sigma (defined in 1.4.18)
%          - integer 'alphatilde': degrees of freedom of the matrix student distribution (defined in 1.4.23)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector 
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)



% start iterations
for ii=1:It-Bu

% draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
B=matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);

% then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
sigma=iwdraw(Sbar,alphabar);

% record values before starting next iteration
beta_gibbs(:,ii)=B(:);
sigma_gibbs(:,ii)=sigma(:);

% go for next iteration
end


