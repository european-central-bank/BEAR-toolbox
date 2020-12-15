function [beta_gibbs omega_gibbs F_gibbs L_gibbs phi_gibbs sigma_gibbs lambda_t_gibbs sigma_t_gibbs sbar]=tvbvar2gibbs(G,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,I_om,H,Xbar,y,alpha0,yt,Xbart,upsilon0,f0,delta0,gamma,pick,pickf)





% preliminary elements for the algorithm
% compute the product G'*I_gamma*G (to speed up computations of deltabar)
GIG=G'*I_om*G;
% set tau as a large value
tau=10000;
% set omega as a large value
om=5;
% compute psibar
chibar=(chi+T)/2;
% compute alphabar
kappabar=T+kappa;
% compute alphabar
alphabar=T+alpha0;


% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices and cells
beta_gibbs=[];
omega_gibbs=[];
F_gibbs=[];
L_gibbs=[];
phi_gibbs=[];
sigma_gibbs=[];
lambda_t_gibbs={};
sigma_t_gibbs={};


% step 1: determine initial values for the algorithm

% initial value for B
B=kron(ones(T,1),betahat);
% initial value Omega
omega=diag(diag(betahat*betahat'));
% invert Omega
invomega=diag(1./diag(omega));
% initial value for f_2,...,f_n
% obtain the triangular factorisation of sigmahat
[Fhat Lambdahat]=triangf(sigmahat);
% obtain the inverse of Fhat
[invFhat]=invltod(Fhat,n);
% create the cell storing the different vectors of invF
Finv=cell(n,1);
% store the vectors
for ii=2:n
Finv{ii,1}=invFhat(ii,1:ii-1);
end
% initial values for L_1,...,L_n
L=zeros(T,n);
% initial values for phi_1,...,phi_n
phi=ones(1,n);
% initiate invsigmabar
invsigmabar=sparse(kron(eye(T),inv(sigmahat)));



% step 2: determine the sbar values and Lambda
sbar=diag(Lambdahat);
Lambda=sparse(diag(sbar));



% step 3: recover the series of initial values for lambda_1,...,lambda_T and sigma_1,...,sigma_T
lambda_t=repmat(diag(sbar),1,1,T);
sigma_t=repmat(sigmahat,1,1,T);

hbar = parfor_progressbar(It,'Progress of the Gibbs sampler');  %create the progress bar

% run the Gibbs sampler
while count<=It
% count

hbar.iterate(1);   % update progress by one iteration


% step 4: draw B
invomegabar=H'*kron(I_tau,invomega)*H+Xbar'*invsigmabar*Xbar;
% compute the choleski of invomegabar
C=chol(nspds(invomegabar),'Lower');
% compute temporary value
temp=Xbar'*invsigmabar*y;
% smoothing phase: solve by back substitution
temp1=C\temp;
% smoothing phase: solve by forward substitution
Bbar=C'\temp1;
% simulation phase:
B=Bbar+C'\randn(q*T,1);
% reshape
Beta=reshape(B,q,T);



% step 5: draw omega from its posterior
% compute the summ
summ=(1/tau)*Beta(:,1)*Beta(:,1)';
for ii=2:T
summ=summ+(Beta(:,ii)-Beta(:,ii-1))*(Beta(:,ii)-Beta(:,ii-1))';
end
summ=diag(summ);
% obtain Qbar
psibar=summ+psi;
% draw omega
omega=diag(arrayfun(@igrandn,kron(ones(q,1),chibar),psibar));
% invert it for next iteration
invomega=diag(1./diag(omega));



% step 6: draw the series f_2,...,f_n from their conditional posteriors
   % recover first the residuals
   for jj=1:T
   epst(:,:,jj)=yt(:,:,jj)-Xbart{jj,1}*Beta(:,jj);
   end
   % then draw the vectors in turn
   for jj=2:n
   % first compute the summations required for upsilonbar and fbar
   summ1=zeros(jj-1,jj-1);
   summ2=zeros(jj-1,1);
      % run the summation
      for kk=1:T
      prodt=epst(1:jj-1,1,kk)*exp(-L(kk,jj));
      summ1=summ1+prodt*epst(1:jj-1,1,kk)';
      summ2=summ2+prodt*epst(jj,1,kk)';
      end
   summ1=(1/sbar(jj,1))*summ1;
   summ2=(-1/sbar(jj,1))*summ2;
   % then obtain the inverse of upsilon0
   invupsilon0=diag(1./diag(upsilon0{jj,1}));
   % obtain upsilonbar
   invupsilonbar=summ1+invupsilon0;
   C=chol(nspd(invupsilonbar));
   invC=C\speye(jj-1);
   upsilonbar=full(invC*invC');
   % recover fbar
   fbar=upsilonbar*(summ2+invupsilon0*f0{jj,1});
   % finally draw f_i^(-1)
   Finv{jj,1}=fbar+chol(nspd(upsilonbar),'lower')*randn(jj-1,1);
   end
% recover the inverse of F
invF=eye(n);
   for jj=2:n
   invF(jj,1:jj-1)=Finv{jj,1};
   end
% eventually recover F
F=invltod(invF,n);
% then update sigma
sigma=F*Lambda*F';



% step 7: draw the series phi_1,...,phi_n from their conditional posteriors
% draw the parameters in turn
   for jj=1:n
   % estimate deltabar
   deltabar=L(:,jj)'*GIG*L(:,jj)+delta0;
   % draw the value phi_i
   phi(1,jj)=igrandn(alphabar/2,deltabar/2);
   end




% step 8: draw the series lambda_i,t from their conditional posteriors, i=1,...,n and t=1,...,T
   % consider variables in turn
   for jj=1:n
      % consider periods in turn
      for kk=1:T
      % a candidate value will be drawn from N(lambdabar,phibar)
      % the definitions of lambdabar and phibar varies with the period, thus define them first
         % if the period is the first period
         if kk==1
         lambdabar=(gamma*L(2,jj))/(1/om+gamma^2);
         phibar=phi(1,jj)/(1/om+gamma^2);
         % if the period is the final period
         elseif kk==T
         lambdabar=gamma*L(T-1,jj);
         phibar=phi(1,jj);
         % if the period is any period in-between
         else
         lambdabar=(gamma/(1+gamma^2))*(L(kk-1,jj)+L(kk+1,jj));
         phibar=phi(1,jj)/(1+gamma^2);
         end
      % now draw the candidate
      cand=lambdabar+phibar^0.5*randn;
      % compute the acceptance probability
      prob=mhprob2(jj,cand,L(kk,jj),sbar(jj,1),epst(:,1,kk),Finv{jj,1});
      % draw a uniform random number
      draw=rand;
         % keep the candidate if the draw value is lower than the prob
         if draw<=prob
         L(kk,jj)=cand;
         % if not, just keep the former value
         end
      end
   end
% then recover the series of matrices lambda_t and sigma_t
for jj=1:T
lambda_t(:,:,jj)=diag(sbar).*diag(exp(L(jj,:)));
sigma_t(:,:,jj)=F*lambda_t(:,:,jj)*F';
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
      % record the results
      beta_gibbs(:,count-Bu)=B;
      omega_gibbs(:,count-Bu)=diag(omega);
      F_gibbs(:,:,count-Bu)=F;
      L_gibbs(:,:,count-Bu)=L;
      phi_gibbs(count-Bu,:)=phi;
      sigma_gibbs(:,count-Bu)=sigma(:);
         for jj=1:T
         lambda_t_gibbs{jj,1}(:,:,count-Bu)=lambda_t(:,:,jj);
         sigma_t_gibbs{jj,1}(:,:,count-Bu)=sigma_t(:,:,jj);
         end  
      % then add one to the count
      count=count+1;
      % if there is post burn selection, only one draw over 'fpick' draws will be retained
      elseif pick==1
         % if the iteration does not correspond to fpick, don't record the results, don't increase the regular count, but do increase pickcount by 1, and do record the acceptance rate of the Metropolis-Hastings step
         if pickcount~=pickf
         pickcount=pickcount+1;
         % on the other hand, if the iteration does correspond to fpick
         elseif pickcount==pickf
         % do record the results
         beta_gibbs(:,count-Bu)=B;
         omega_gibbs(:,count-Bu)=diag(omega);
         F_gibbs(:,:,count-Bu)=F;
         L_gibbs(:,:,count-Bu)=L;
         phi_gibbs(count-Bu,:)=phi;
         sigma_gibbs(:,count-Bu)=sigma(:);
            for jj=1:T
            lambda_t_gibbs{jj,1}(:,:,count-Bu)=lambda_t(:,:,jj);
            sigma_t_gibbs{jj,1}(:,:,count-Bu)=sigma_t(:,:,jj);
            end
         % then increase the regular count by 1 and re-initialise pickcount
         count=count+1;
         pickcount=1;
         end
      end
   end
end
close(hbar);   %close progress bar


% turn beta_gibbs into cell
beta_gibbs=mat2cell(beta_gibbs,repmat(q,T,1),It-Bu);





