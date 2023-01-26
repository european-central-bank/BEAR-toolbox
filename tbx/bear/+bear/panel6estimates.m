function [theta_median theta_std theta_lbound theta_ubound sigma_median]=panel6estimates(d,N,n,T,theta_gibbs,sigma_gibbs,cband)


% obtain point estimates for the structural factors
% loop over sample periods
for ii=1:T
   % loop over structural factors
   for jj=1:d
   theta_median(jj,1,ii)=[quantile(theta_gibbs(jj,:,ii),0.5)];
   theta_std(jj,1,ii)=std(theta_gibbs(jj,:,ii));
   theta_lbound(jj,1,ii)=[quantile(theta_gibbs(jj,:,ii),(1-cband)/2)];
   theta_ubound(jj,1,ii)=[quantile(theta_gibbs(jj,:,ii),1-(1-cband)/2)];
   end
end


% obtain point estimates for sigma
% loop over sample periods
for ii=1:T
   % loop over sigma entries
   for jj=1:(N*n)^2
   sigma_median(jj,1,ii)=[quantile(sigma_gibbs(jj,:,ii),0.5)];
   end
end
