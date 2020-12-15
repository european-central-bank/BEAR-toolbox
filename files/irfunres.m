function [D_record gamma_record]=irfunres(n,It,Bu,sigma_gibbs)




% function [D_record gamma_record]=irfunres(n,It,Bu,sigma_gibbs)
% creates records for D and gamma, for the trivial identification scheme
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
% outputs: - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma



% generate record of structural matrix D (required for historical decomposition)
% because there is no decomposition with unrestricted VAR models, the structural decomposition matrix is just identity
D_record=repmat(reshape(eye(n),n^2,1),1,It-Bu);

% Take care of gamma, the variance-covariance matrix of the structural disturbances
% because there is no transformation in reduced form VARs, gamma is just the covariance matrix sigma
gamma_record=sigma_gibbs;






