function [theta_gibbs sigmatilde_gibbs Zeta_gibbs sigma_gibbs phi_gibbs B_gibbs acceptrate]=panel6gibbs(y,Xtilde,N,n,T,theta0,Theta0,thetabar,alpha0,delta0,a0,b0,psi,d1,d2,d3,d4,d5,d,It,Bu,H,G,pick,pickf,gama)







% compute first  preliminary elements
% compute the series of abar values
a1bar=T*d1+a0;
a2bar=T*d2+a0;
a3bar=T*d3+a0;
a4bar=T*d4+a0;
a5bar=T*d5+a0;
% compute alphabar
alphabar=T+alpha0;


% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices
theta_gibbs=zeros(d,It-Bu,T);
sigmatilde_gibbs=zeros((N*n)^2,It-Bu);
Zeta_gibbs=zeros(T,It-Bu);
phi_gibbs=zeros(1,It-Bu);
b_gibbs=zeros(5,It-Bu);
sigma_gibbs=zeros((N*n)^2,It-Bu,T);
% initiate total accepted draws and total draws
totaccept=0;
totdraws=0;

% step 1: compute initial values
% initial value for Theta
Theta=repmat(thetabar,T,1);
% initial value for b, the varainces of the 5 structural factors
b=10000*ones(5,1);
% initial value for sigmatilde
eps=reshape(y-Xtilde*Theta,N*n,T);
sigmatilde=(1/T)*eps*eps';
% initial value for Zeta
Zeta=zeros(T,1);
% initial value for phi
phi=0.001;






hbar = parfor_progressbar(It-Bu,'Progress of Panel BVAR Gibbs Sampler');  %create the progress bar

% run the Gibbs sampler
while count<=It


% step 2: obtain sigmatilde
% compute Sbar
% because using a loop is slow, express the summation as a matrix product
% compute in matrix form the series of residuals yt-Xt*thetat
eps=sparse(reshape(y-Xtilde*Theta,N*n,T));
% create a diagonal matrix for which each diagonal entry is a zeta value
zetamat=sparse(diag(exp(-Zeta)));
% obtain Sbar
Sbar=full(eps*zetamat*eps');
% finally draw sigmatilde
sigmatilde=iwdraw(Sbar,T);
invsigmatilde=sigmatilde\speye(n*N);


% step 3: obtain Zeta
eps=eps';
% compute in matrix form the series of residuals yt-Xt*thetat
for tt=1:T
% obtain the residual product for the acceptance probability
term=eps(tt,:)*invsigmatilde*eps(tt,:)';
% obtain phibar
   if tt==1
   phibar=phi/(1+gama^2);
   zetabar=(phibar/phi)*gama*Zeta(2,1);
   elseif tt==T
   phibar=phi;  
   zetabar=gama*Zeta(T-1,1) ;
   else
   phibar=phi/(1+gama^2);
   zetabar=(phibar/phi)*gama*(Zeta(tt-1,1)+Zeta(tt+1,1));
   end
% obtain a candidate value
cand=zetabar+sqrt(phibar)*randn;
% obtain the probability of acceptance
[prob]=mhprob(Zeta(tt,1),cand,term,n,N);
% draw a uniform random number
draw=rand;
   % keep the candidate if the draw value is lower than the prob
   if draw<=prob
   Zeta(tt,1)=cand;
   % record acceptance
   accept=1;
   % if not, just keep the former value and record non-acceptance
   else
   accept=0;
   end
end



% step 4: obtain phi
% obtain deltabar
deltabar=Zeta'*G'*G*Zeta+delta0;
% draw phi
phi=igrandn(alphabar/2,deltabar/2);



% step 5: obtain the series of bi values
% first reshape the Theta vector so that each column corresponds to a sample period
Thetamat=reshape(Theta,d,T);
% then draw b values for each structural factor in turn

% factor 1 (common component)
% extract the theta component related to structural factor 1 (for all periods)
theta1=Thetamat(1:d1,:);
% obtain lagged values
theta1lag=[theta0(1:d1,1) theta1(:,1:end-1)];
% generate the difference
theta1diff=theta1-theta1lag;
% obtain the summation
summ1=vec(theta1diff)'*vec(theta1diff);
% obtain b1bar
b1bar=summ1+b0;
% draw b1
b1=igrandn(a1bar/2,b1bar/2);

% factor 2 (unit component)
% extract the theta component related to structural factor 2 (for all periods)
theta2=Thetamat(d1+1:d1+d2,:);
% obtain lagged values
theta2lag=[theta0(d1+1:d1+d2,1) theta2(:,1:end-1)];
% generate the difference
theta2diff=theta2-theta2lag;
% obtain the summation
summ2=vec(theta2diff)'*vec(theta2diff);
% obtain b1bar
b2bar=summ2+b0;
% draw b2
b2=igrandn(a2bar/2,b2bar/2);

% factor 3 (endogenous variable component)
% extract the theta component related to structural factor 3 (for all periods)
theta3=Thetamat(d1+d2+1:d1+d2+d3,:);
% obtain lagged values
theta3lag=[theta0(d1+d2+1:d1+d2+d3,1) theta3(:,1:end-1)];
% generate the difference
theta3diff=theta3-theta3lag;
% obtain the summation
summ3=vec(theta3diff)'*vec(theta3diff);
% obtain b1bar
b3bar=summ3+b0;
% draw b3
b3=igrandn(a3bar/2,b3bar/2);

% factor 4 (lag component, only if the model includes more than one lag)
   if d4~=0
   % extract the theta component related to structural factor 4 (for all periods)
   theta4=Thetamat(d1+d2+d3+1:d1+d2+d3+d4,:);
   % obtain lagged values
   theta4lag=[theta0(d1+d2+d3+1:d1+d2+d3+d4,1) theta4(:,1:end-1)];
   % generate the difference
   theta4diff=theta4-theta4lag;
   % obtain the summation
   summ4=vec(theta4diff)'*vec(theta4diff);
   % obtain b1bar
   b4bar=summ4+b0;
   % draw b4
   b4=igrandn(a4bar/2,b4bar/2);
   else 
   b4=nan;
   end

% factor 5 (exogenous variable component, only if the model includes at least one exogenous)
   if d5~=0
   % extract the theta component related to structural factor 4 (for all periods)
   theta5=Thetamat(d1+d2+d3+d4+1:d1+d2+d3+d4+d5,:);
   % obtain lagged values
   theta5lag=[theta0(d1+d2+d3+d4+1:d1+d2+d3+d4+d5,1) theta5(:,1:end-1)];
   % generate the difference
   theta5diff=theta5-theta5lag;
   % obtain the summation
   summ5=vec(theta5diff)'*vec(theta5diff);
   % obtain b1bar
   b5bar=summ5+b0;
   % draw b5
   b5=igrandn(a5bar/2,b5bar/2);
   else 
   b5=nan;
   end



% step 6: obtain Theta
% first generate B
B=sparse(blkdiag(b1*eye(d1),b2*eye(d2),b3*eye(d3),b4*eye(d4),b5*eye(d5)));
% then obtain the inverse of B0: since B0=H-1*Btilde*(H-1)', then inv(Bo)=H'*Btilde-1*H=H'*kron(eye(T),B-1)-1*H
% obtain first the inverse of B; B is diagonal, so just take elementwise inverse of diagonal entries
invB=sparse(diag(1./diag(B)));
% then obtain the inverse of B0
invB0=H'*kron(eye(T),invB)*H;
% compute Sigma
Sigma=kron(sparse(diag(exp(Zeta))),sigmatilde);
% obtain the inverse
C=trns(chol(nspd(full(Sigma)),'Lower'));
invC=C\speye(T*N*n);
invSigma=invC*invC';
% obtain Bbar
invBbar=(Xtilde'*invSigma*Xtilde+invB0);
% obtain the inverse
C=trns(chol(nspd(full(invBbar)),'Lower'));
invC=C\speye(T*d);
Bbar=invC*invC';
% obtain Thetabar
Thetabar=Bbar*(Xtilde'*invSigma*y+invB0*Theta0);
% draw Theta
Theta=Thetabar+chol(nspd(Bbar),'lower')*mvnrnd(zeros(d*T,1),eye(d*T))';



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
      sigmatilde_gibbs(:,count-Bu)=vec(sigmatilde);
      Zeta_gibbs(:,count-Bu)=Zeta;
      phi_gibbs(1,count-Bu)=phi;
      B_gibbs(:,count-Bu)=B(:);
      theta_gibbs(:,count-Bu,:)=reshape(Theta,d,1,T);
      % recover sigma for all periods and record      
      temp=kron(exp(Zeta),vec(sigmatilde));
      sigma_gibbs(:,count-Bu,:)=reshape(temp,(N*n)^2,T);
      % record acceptance rate of Metropolis-Hastings step
      totaccept=totaccept+accept;  
      totdraws=totdraws+1;  
      % and add one to the count
      count=count+1;
      % if there is post burn selection, only one draw over 'fpick' draws will be retained
      elseif pick==1
         % if the iteration does not correspond to fpick, don't record the results, don't increase the regular count, but do increase pickcount by 1, and do record the acceptance rate of the Metropolis-Hastings step
         if pickcount~=pickf
         pickcount=pickcount+1;
         totaccept=totaccept+accept;  
         totdraws=totdraws+1; 
         % on the other hand, if the iteration does correspond to fpick
         elseif pickcount==pickf
         % do record the results
         sigmatilde_gibbs(:,count-Bu)=vec(sigmatilde);
         Zeta_gibbs(:,count-Bu)=Zeta;
         phi_gibbs(1,count-Bu)=phi;
         B_gibbs(:,count-Bu)=B(:);
         theta_gibbs(:,count-Bu,:)=reshape(Theta,d,1,T);
         % recover sigma for all periods and record      
         temp=kron(exp(Zeta),vec(sigmatilde));
         sigma_gibbs(:,count-Bu,:)=reshape(temp,(N*n)^2,T);
         % do record the acceptance rate of the Metropolis-Hastings step
         totaccept=totaccept+accept;  
         totdraws=totdraws+1;
         % then increase the regular count by 1 and re-initialise pickcount
         count=count+1;
         pickcount=1;
         end
      end
   end
   hbar.iterate(1);   % update progress by one iteration


end

close(hbar);   %close progress bar

% eventually compute the accpetance rate of the Metropolis-Hastings step for the complete run of the Gibbs sampler
acceptrate=100*(totaccept/totdraws);





