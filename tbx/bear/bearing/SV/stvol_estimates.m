function [beta_median beta_std beta_lbound beta_ubound sigma_median sigma_t_median sigma_t_lbound sigma_t_ubound gamma_median]=stvol_estimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T,cband,varargin)

if ~isempty(varargin)
   gamma_gibbs = varargin{1};
   % compute the estimates for gamma
   gamma_median=quantile(gamma_gibbs,0.5,1);
else
   gamma_median = [];
end

% compute the median, variance, and credibility intervals for the posterior distribution of beta
beta_median=quantile(beta_gibbs,0.5,2);
beta_std=std(beta_gibbs,0,2);
beta_lbound=quantile(beta_gibbs,(1-cband)/2,2);
beta_ubound=quantile(beta_gibbs,1-(1-cband)/2,2);


% compute the results for sigma (long-run value)
sigma_median=reshape(quantile(sigma_gibbs,0.5,2),n,n);


% compute the rsults for sigma (sample values)
sigma_t_median=cell(n,n);
sigma_t_lbound=cell(n,n);
sigma_t_ubound=cell(n,n);
% loop over periods and entries
for ii=1:T
   for jj=1:n
      for kk=1:jj
      sigma_t_median{jj,kk}(ii,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),0.5,3);
      sigma_t_lbound{jj,kk}(ii,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),(1-cband)/2,3);
      sigma_t_ubound{jj,kk}(ii,1)=quantile(sigma_t_gibbs{ii,1}(jj,kk,:),1-(1-cband)/2,3);
      end
   end
end



            






