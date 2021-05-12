function [theta_gibbs,sigma_gibbs,sigmatilde_gibbs,sig_gibbs]=panel5gibbs(y,Y,Xtilde,Xdot,N,n,T,d,theta0,Theta0,alpha0,delta0,It,Bu,pick,pickf)














% compute first  preliminary elements
% compute alphabar
alphabar=N*n*T+alpha0;
% compute the inverse Theta0
invTheta0=sparse(diag(1./diag(Theta0)));
% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices
theta_gibbs=zeros(d,It-Bu);
sigmatilde_gibbs=zeros((N*n)^2,It-Bu);
sig_gibbs=zeros(1,It-Bu);
sigma_gibbs=zeros((N*n)^2,It-Bu);


% step 1: compute initial values
% initial value for theta (use OLS values)
theta=(Xtilde*Xtilde')\(Xtilde*y);
% initial value for sigmatilde (use residuals form OLS values)
eps=y-Xtilde'*theta;
eps=reshape(eps,T,N*n);
sigmatilde=eps'*eps;
% initiate value for the sigma, the scaling term for the errors
sig=1;
% initiate value for the matrix sigma, the residual variance-covariance matrix
sigma=sig*sigmatilde;
% initiate value for eyesigma
% compute the inverse of sigma
C=trns(chol(nspd(sigma),'Lower'));
invC=C\speye(N*n);
invsigma=invC*invC';
% then compute eyesigma
eyesigma=kron(speye(T),invsigma);
% finally, initiate eyetheta
eyetheta=kron(speye(T),theta);

hbar = parfor_progressbar(It-Bu,'Progress of Panel BVAR Gibbs Sampler.');  %create the progress bar

% run the Gibbs sampler
while count<=It

% step 2: obtain sigmatilde
% compute Sbar
Sbar=(1/sig)*(Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)';
sigmatilde=iwdraw(Sbar,T);

% step 3: obtain sig
% compute the inverse of sigmatilde
C=trns(chol(nspd(sigmatilde),'Lower'));
invC=C\speye(N*n);
invsigmatilde=invC*invC';
% compute deltabar
deltabar=trace((Y-Xdot*eyetheta)*(Y-Xdot*eyetheta)'*invsigmatilde)+delta0;
% draw sig
sig=igrandn(alphabar/2,deltabar/2);

% step 4: compute sigma and eyesigma
sigma=sig*sigmatilde;
C=trns(chol(nspd(sigma),'Lower'));
invC=C\speye(N*n);
invsigma=invC*invC';
eyesigma=kron(speye(T),invsigma);

% step 5: obtain theta
% compute Thetabar
invThetabar=full((Xtilde*eyesigma*Xtilde'+invTheta0));
C=trns(chol(nspd(invThetabar),'Lower'));
invC=C\speye(d);
Thetabar=invC*invC';
% compute thetabar
thetabar=Thetabar*(Xtilde*eyesigma*y+invTheta0*theta0);
% draw theta
theta=thetabar+chol(nspd(Thetabar),'lower')*mvnrnd(zeros(d,1),eye(d))';

% step 6: obtain eyetheta
eyetheta=kron(speye(T),theta);


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
      theta_gibbs(:,count-Bu)=theta;
      sigmatilde_gibbs(:,count-Bu)=vec(sigmatilde);
      sig_gibbs(1,count-Bu)=sig;
      sigma_gibbs(:,count-Bu)=vec(sigma);
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
         theta_gibbs(:,count-Bu)=theta;
         sigmatilde_gibbs(:,count-Bu)=vec(sigmatilde);
         sig_gibbs(1,count-Bu)=sig;
         sigma_gibbs(:,count-Bu)=vec(sigma);
         % then increase the regular count by 1 and re-initialise pickcount
         count=count+1;
         pickcount=1;
         end
      end
   end

   hbar.iterate(1);   % update progress by one iteration

end

close(hbar);   %close progress bar

