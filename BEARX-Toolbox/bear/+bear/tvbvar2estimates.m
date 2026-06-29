function [beta_t_median beta_t_std beta_t_lbound beta_t_ubound omega_median sigma_median sigma_t_median sigma_t_lbound sigma_t_ubound]=tvbvar2estimates(beta_gibbs,omega_gibbs,F_gibbs,L_gibbs,phi_gibbs,sigma_gibbs,lambda_t_gibbs,sigma_t_gibbs,n,q,T,cband)



% compute the results for the beta coefficients (sample values)
beta_t_median=cell(q,1);
beta_t_std=cell(q,1);
beta_t_lbound=cell(q,1);
beta_t_ubound=cell(q,1);
% loop over periods and entries
for ii=1:T
   for jj=1:q
   beta_t_median{jj,1}(ii,1)=quantile(beta_gibbs{ii,1}(jj,:),0.5,2);
   beta_t_std{jj,1}(ii,1)=std(beta_gibbs{ii,1}(jj,:),0,2);
   beta_t_lbound{jj,1}(ii,1)=quantile(beta_gibbs{ii,1}(jj,:),(1-cband)/2,2);
   beta_t_ubound{jj,1}(ii,1)=quantile(beta_gibbs{ii,1}(jj,:),1-(1-cband)/2,2);
   end
end



% compute the median, variance, and credibility intervals for the posterior distribution of omega
omega_median=quantile(omega_gibbs,0.5,2);
omega_std=std(omega_gibbs,0,2);
omega_lbound=quantile(omega_gibbs,(1-cband)/2,2);
omega_ubound=quantile(omega_gibbs,1-(1-cband)/2,2);



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









