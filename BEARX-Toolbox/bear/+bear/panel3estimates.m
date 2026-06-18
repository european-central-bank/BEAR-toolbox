function [beta_median beta_std beta_lbound beta_ubound sigma_median]=panel3estimates(N,n,q,betabar,omegabarb,sigeps,cband)
















% compute the mean, variance, and credibility intervals for the posterior distribution of beta
% first reshape betabar to simplify computations
Bbar=reshape(betabar,q,N);
% take the diagonal of omegabarb to retain only the variance terms of the VAR coefficients
bvar=full(diag(omegabarb));
% reshape
Bvar=reshape(bvar,q,N);

% as the VAR coefficients are estimated for each unit, loop over units
for ii=1:N
   for jj=1:q
   beta_median(jj,1,ii)=Bbar(jj,ii);
   beta_std(jj,1,ii)=Bvar(jj,ii)^0.5;
   beta_lbound(jj,1,ii)=norminv((1-cband)/2,beta_median(jj,1,ii),beta_std(jj,1,ii));
   beta_ubound(jj,1,ii)=norminv((1-(1-cband)/2),beta_median(jj,1,ii),beta_std(jj,1,ii));
   end
end

% compute the results for sigma
% write sigma resulting from the prior in vectorized form
sigma_median=sigeps*eye(n);










