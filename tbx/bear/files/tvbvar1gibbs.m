function [beta_gibbs,omega_gibbs,sigma_gibbs]=tvbvar1gibbs_v2(S,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,H,Xbar,y)




% preliminary elements for the algorithm
% set tau as a large value
tau=10000;
% compute psibar
chibar=(chi+T)/2;
% compute alphabar
kappabar=T+kappa;



% initiate the Gibbs sampler
% initiate the counting of iterations
count=1;
pickcount=1;
% initiate the record matrices and cells
beta_gibbs=[];
omega_gibbs=[];
sigma_gibbs=[];




% step 1: determine initial values for the algorithm

% initial value for B
B=kron(ones(T,1),betahat);
% initial value Omega
omega=diag(diag(betahat*betahat'));
% invert Omega
invomega=diag(1./diag(omega));
% initial value for sigma
sigma=sigmahat;
% invert sigma
C=trns(chol(nspd(sigma),'Lower'));
invC=C\speye(n);
invsigma=invC*invC';
% obtain the inverse of sigmabar
%invsigmabar=sparse(kron(eye(T),invsigma));

%% Let's redo X'X and X'Y

pre_xx = Xbar'*kron(speye(T),ones(n,n))*Xbar;   % like setting invsigma to a matrix of (n,n) ones

pre_xy = NaN(T*q,n);
for i=1:T
    pre_xy(1+(i-1)*q:i*q,:) = kron(ones(n,1),kron(y(1+(i-1)*n:i*n)',Xbar(1+n*(i-1),1+q*(i-1):q*(i-1)+q/n)'));
end

H_status_bar = waitbar(0,'Gibbs sampling in progress   0%');

percentage = floor(It/100);

%% run the Gibbs sampler
while count<=It

if mod(count,percentage) == 0
    waitbar(count/It,H_status_bar,['Gibbs samping in progress   ',num2str(floor(count/It*100)),'%']);
end



% step 2: draw B
invomegabar = H'*kron(I_tau,invomega)*H + kron(speye(T),kron(invsigma,ones(q/n,q/n))).*pre_xx;
% compute temporary value
temp = sum(kron(ones(T,1),kron(invsigma,ones(q/n,1))).*pre_xy,2);
% solve
Bbar = invomegabar\temp;
% simulation phase:
B=Bbar+chol(invomegabar,'Lower')'\randn(q*T,1);
% reshape
Beta=reshape(B,q,T);



% step 3: draw omega from its posterior
% compute psibar
psibar=(1/tau)*Beta(:,1).^2+sum((Beta(:,2:T)-Beta(:,1:T-1)).^2,2)+psi;
% draw omega
omega=diag(arrayfun(@igrandn,kron(ones(q,1),chibar),psibar/2));
% invert it for next iteration
invomega=diag(1./diag(omega));



% step 4: draw sigma from its posterior
%estimate the residuals
eps=y-Xbar*B;
Eps=reshape(eps,n,T);
% estimate Sbar
Sbar=Eps*Eps'+S;
% draw sigma
sigma=iwdraw(Sbar,kappabar);
% invert it for next iteration
C=trns(chol(nspd(sigma),'Lower'));
invC=C\speye(n);
invsigma=invC*invC';



% record phase
   % if the burn-in sample phase is not yet over
   if count<=Bu
   % simply add 1 to the iteration count
   count=count+1;
   % on the other hand, if the burn-in sample phase is over
   elseif count>Bu
       if count == Bu+1
           disp('Burn in finished, storing results');
       end
   % record the results
   beta_gibbs(:,count-Bu)=B;
   omega_gibbs(:,count-Bu)=diag(omega);
   sigma_gibbs(:,count-Bu)=sigma(:); 
   % then add one to the count
   count=count+1;
   end



end
close(H_status_bar);
% turn beta_gibbs into cell
beta_gibbs=mat2cell(beta_gibbs,repmat(q,T,1),It-Bu);





