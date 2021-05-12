function [beta_swap]=betaswap(beta_gibbs,n,m,p,k)



% function [beta_swap]=betaswap(beta_gibbs,n,m,p,k)
% reorganizes the matrix of gibbs sampler draws of beta, in order to make it easier to plot with matlab "subplot" function
% used to plot the empirical posterior distributions
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_swap': a reorganised gibbs sampler matrix




for ii=1:n
   for jj=1:n
      for kk=1:p
      beta_swap((ii-1)*k+(jj-1)*p+kk,:)=beta_gibbs((ii-1)*k+n*(kk-1)+jj,:);
      end
   end
end

for ii=1:n
beta_swap(ii*k-m+1:ii*k,:)=beta_gibbs(ii*k-m+1:ii*k,:);
end







































