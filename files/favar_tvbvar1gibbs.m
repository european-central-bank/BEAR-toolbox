function [beta_gibbs,omega_gibbs,sigma_gibbs,favar]=favar_tvbvar1gibbs(S,sigmahat,T,chi,psi,kappa,betahat,q,n,It,Bu,I_tau,H,Xbar,y,data_endo,lags,favar)

%% preliminaries
% initialise variables
nfactorvar=favar.nfactorvar;
numpc=favar.numpc;
favarX=favar.X(:,favar.plotX_index);
onestep=favar.onestep;
Sigma=nspd(favar.Sigma);
favar_X=favar.X;
L=favar.L;
% load priors
L0=favar.L0*eye(n);
a0=favar.a0;
b0=favar.b0;
% sigmahat=(1/T)*(EPS'*EPS);

% preallocation
L_gibbs=zeros(size(L(:),1),It-Bu);
R2_gibbs=zeros(size(favarX,2),It-Bu);

if onestep==0 %static factors in this case
    FY=data_endo;
    pbstring='two-step'; %string for the progress bar
    % elseif onestep==1
    %     pbstring='one-step'; %string for the progress bar
end

% % state-space representation
% B_ss=[B';eye(n*(lags-1)) zeros(n*(lags-1),n)];
% sigma_ss=[sigmahat zeros(n,n*(lags-1));zeros(n*(lags-1),n*lags)];


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
% pickcount=1;
% initiate the record matrices and cells
beta_gibbs=[];
omega_gibbs=[];
sigma_gibbs=[];




% step 1: determine initial values for the algorithm

% initial value for B
% B=kron(ones(T,1),betahat);
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

% create a progress bar
hbar = parfor_progressbar(It,['Progress of the Gibbs sampler (',pbstring,').']);

%% run the Gibbs sampler
while count<=It
    
    
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
    
    %% Sample Sigma and L (static)
    [Sigma,L]=favar_SigmaL(Sigma,L,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,lags,L0);
    
    %% record phase
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
        
        % save the factors and loadings (keep the notation in the code consistent, although - except L - they don't change)
        L_gibbs(:,count-Bu)=L(:);
        
        % compute R2 (Coefficient of Determination) for plotX variables (keep the notation in the code consistent, although they don't change)
        R2=favar_R2(favarX,FY);
        R2_gibbs(:,count-Bu)=R2(:);
        
        % then add one to the count
        count=count+1;
    end
    
    % update progress by one iteration
    hbar.iterate(1);
    
    % go for next iteration
end

% in case we have thinning of the draws,
thin=abs(round(favar.thin)); % should be a positive integer
if thin~=1
    beta_gibbs=beta_gibbs(:,thin:thin:end);
    omega_gibbs=omega_gibbs(:,thin:thin:end);
    sigma_gibbs=sigma_gibbs(:,thin:thin:end);
    L_gibbs=L_gibbs(:,thin:thin:end);
    R2_gibbs=R2_gibbs(:,thin:thin:end);
    It=(1/thin)*It;
    Bu=(1/thin)*Bu;
end

% save in favar structure
% favar.X_gibbs=X_gibbs;
% favar.Y_gibbs=Y_gibbs;
% favar.FY_gibbs=FY_gibbs;
favar.L_gibbs=L_gibbs;
favar.R2_gibbs=R2_gibbs;

% close progress bar
close(hbar);

% turn beta_gibbs into cell
beta_gibbs=mat2cell(beta_gibbs,repmat(q,T,1),It-Bu);


