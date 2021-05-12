function [beta_gibbs,sigma_gibbs]=panel3gibbs(It,Bu,betabar,omegabarb,sigeps,h,N,n,q)










beta_gibbs=[];
% start iterations
hbar = parfor_progressbar(It-Bu,'Progress of Panel BVAR Gibbs Sampler.');  %create the progress bar
for ii=1:(It-Bu)
% draw a random vector beta from N(betabar,omegabarb)
beta=betabar+chol(nspd(omegabarb),'lower')*mvnrnd(zeros(h,1),eye(h))';
beta=reshape(beta,q,N);
   % record values by marginalising over each unit
   for jj=1:N
   beta_gibbs(:,ii,jj)=beta(:,jj);
   end
% go for next iteration
   hbar.iterate(1);   % update progress by one iteration

end
close(hbar);   %close progress bar

% obtain a record of draws for sigma, the residual variance-covariance matrix
% compute sigma
sigma=sigeps*eye(n);
% duplicate

sigma_gibbs=repmat(sigma(:),[1 It-Bu N]);
































































