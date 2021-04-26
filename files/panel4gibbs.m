function [beta_gibbs,sigma_gibbs,beta_mean,sigma_mean,lambda_posterior]=panel4gibbs(N,n,h,T,k,q,Yi,Xi,s0,omegab,v0,It,Bu,pick,pickf)





% compute first  preliminary elements
% compute sbar
sbar=h+s0;
% compute the inverse of omegab
invomegab=diag(1./diag(omegab));
% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices
beta_gibbs=zeros(q,It-Bu,N);
sigma_gibbs=zeros(n^2,It-Bu,N);
beta_mean=zeros(q,It-Bu);
sigma_mean=zeros(n^2,It-Bu);
lambda_posterior=zeros((It-Bu),1);

% step 1: compute initial values
% initial value for beta (use OLS values)
for ii=1:N
beta(:,ii)=vec((Xi(:,:,ii)'*Xi(:,:,ii))\(Xi(:,:,ii)'*Yi(:,:,ii)));
end
% initial value for b
b=(1/N)*sum(beta,2);
% initial value for lambda1
lambda1=0.01;
sigmab=lambda1*omegab;
% initial value for sigma (use OLS values)
for ii=1:N
eps=Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,n);
sigma(:,:,ii)=(1/(T-k-1))*eps'*eps;
end


hbar = parfor_progressbar(It-Bu,'Progress of Panel BVAR Gibbs Sampler');  %create the progress bar


% run the Gibbs sampler
while count<=It

% step 2: obtain b
% first compute betam, the mean value of the betas over all units
betam=(1/N)*sum(beta,2);
% draw b from a multivariate normal N(betam,(1/N)*sigmab))
b=betam+chol(nspd((1/N)*sigmab),'lower')*mvnrnd(zeros(q,1),eye(q))';


% step 3: obtain sigmab
% compute first vbar
for ii=1:N
temp(1,ii)=(beta(:,ii)-b)'*invomegab*(beta(:,ii)-b);
end
vbar=v0+sum(temp,2);
% compute lambda1
lambda1=igrandn(sbar/2,vbar/2);
% recover sigmab
sigmab=lambda1*omegab;


% step 4: draw the series of betas
% first obtain the inverse of sigmab
invsigmab=diag(1./diag(sigmab));
% then loop over units
for ii=1:N
% take the choleski factor of sigma of unit ii, inverse it, and obtain from it the inverse of the original sigma
C=trns(chol(nspd(sigma(:,:,ii)),'Lower'));
invC=C\speye(n);
invsigma=invC*invC';
% obtain omegabar
invomegabar=kron(invsigma,Xi(:,:,ii)'*Xi(:,:,ii))+invsigmab;
% invert
C=trns(chol(nspd(invomegabar),'Lower'));
invC=C\speye(q);
omegabar=invC*invC';
% obtain betabar
betabar=omegabar*(kron(invsigma,Xi(:,:,ii)')*vec(Yi(:,:,ii))+invsigmab*b);
% draw beta
beta(:,ii)=betabar+chol(nspd(omegabar),'lower')*mvnrnd(zeros(q,1),eye(q))';
end


% step 5: draw the series of sigmas
% loop over units
for ii=1:N
% compute Stilde
Stilde=(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,n))'*(Yi(:,:,ii)-Xi(:,:,ii)*reshape(beta(:,ii),k,n));
% draw sigma
sigma(:,:,ii)=iwdraw(Stilde,T);
end


   % record phase
   % if the burn-in sample phase is not yet over
   if count<=Bu
   % simply add 1 to the iteration count
   count=count+1;
   % on the other hand, if the burn-in sample phase is over
   elseif count>Bu
   % adding one iteration to the count will depend on wether post-burn selection applies
      % if there is no post burn selection
      if pick==0
      % record the draw
         % loop over units
         for ii=1:N
         beta_gibbs(:,count-Bu,ii)=beta(:,ii);
         sigma_gibbs(:,count-Bu,ii)=vec(sigma(:,:,ii));
         end
      % and add one to the count
      count=count+1;
      % if there is post burn selection, only one draw over 'fpick' draws will be retained
      elseif pick==1
         % if the iteration does not correspond to fpick, don't record the results, don't increase the regular count, but do increase pickcount by 1
         if pickcount~=pickf
         pickcount=pickcount+1;
         % on the other hand, if the iteration does correspond to fpick
         elseif pickcount==pickf
         % do record the results
            % loop over units
            beta_mean(:,count-Bu)=b;
            sigma_mean(:,count-Bu)=vec(mean(sigma,3));
            lambda_posterior(count-Bu)=lambda1;
            for ii=1:N
            beta_gibbs(:,count-Bu,ii)=beta(:,ii);
            sigma_gibbs(:,count-Bu,ii)=vec(sigma(:,:,ii));
            end
         % then increase the regular count by 1 and re-initialise pickcount
         count=count+1;
         pickcount=1;
         end
      end
   end
   
   hbar.iterate(1);   % update progress by one iteration

end

close(hbar);   %close progress bar

