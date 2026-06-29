function [theta_median theta_std theta_lbound theta_ubound sigma_median]=panel5estimates(d,N,n,theta_gibbs,sigma_gibbs,cband)



% loop over structural factors
for ii=1:d
theta_median(ii,1)=[quantile(theta_gibbs(ii,:),0.5)];
theta_std(ii,1)=std(theta_gibbs(ii,:));
theta_lbound(ii,1)=[quantile(theta_gibbs(ii,:),(1-cband)/2)];
theta_ubound(ii,1)=[quantile(theta_gibbs(ii,:),1-(1-cband)/2)];
end


% loop over sigma entries
for ii=1:(N*n)^2
sigma_median(ii,1)=[quantile(sigma_gibbs(ii,:),0.5)];
end


