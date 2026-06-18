function [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,beta_mean_median,beta_mean_lbound,beta_mean_ubound,sigma_mean_median]...
    =panel4estimates(N,n,q,beta_gibbs,sigma_gibbs,cband, beta_mean,sigma_mean)


% compute first the  percentiles for the mean model values, i.e. beta_mean
% and sigma_man
% 
% for jj=1:n^2
%  sigma_mean_median(jj,1)=[quantile(sigma_mean(jj,:),0.5)];
% end
%    for jj=1:q
%    beta_mean_median(jj,1)=[quantile(beta_mean(jj,:),0.5)];
%    beta_mean_lbound(jj,1)=[quantile(beta_gibbs(jj,1),(1-cband)/2)];
%    beta_mean_ubound(jj,1)=[quantile(beta_gibbs(jj,1),1-(1-cband)/2)];
%    end
% as the VAR coefficients are estimated for each unit, loop over units
% move to the country specific coefficients
for ii=1:N
   % loop over VAR coefficients
   for jj=1:q
   beta_median(jj,1,ii)=[quantile(beta_gibbs(jj,:,ii),0.5)];
   beta_std(jj,1,ii)=std(beta_gibbs(jj,:,ii));
   beta_lbound(jj,1,ii)=[quantile(beta_gibbs(jj,1,ii),(1-cband)/2)];
   beta_ubound(jj,1,ii)=[quantile(beta_gibbs(jj,1,ii),1-(1-cband)/2)];
   end
   % loop over sigma entries
   for jj=1:n^2
   sigma_median(jj,1,ii)=[quantile(sigma_gibbs(jj,:,ii),0.5)];
   end
end







