function [beta_gibbs,sigma_gibbs,favar,It,Bu]=favar_dogibbs(It,Bu,B,EPS,n,T,lags,data_endo,data_exo,const,favar,ar,arvar,lambda1,lambda3,lambda4,m,p,k,priorexo,Y,X,cband,Tstar)

%% the methodolgy closely follows Bernanke, Boivin, Eliasz (2005) and lends from the FAVAR model of Koop & Korobilis 

% function [beta_gibbs sigma_gibbs]=ndgibbs(It,Bu,beta0,omega0,X,Y,y,Bhat,n,T,q)
% performs the Gibbs algorithm 1.5.2 for the normal-diffuse prior, and returns draws from posterior distribution
% inputs:  - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - vector 'y': vectorised regressands for the VAR model (defined in 1.1.12)
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)


%% preliminary tasks
% initialise variables
nfactorvar=favar.nfactorvar;
numpc=favar.numpc;
favarX=favar.X(:,favar.plotX_index);
onestep=favar.onestep;
XY=favar.XY;

    % initial conditions XZ0~N(XZ0mean,XZ0var)
    favar.XZ0mean=zeros(n*lags,1);
    favar.XZ0var=favar.L0*eye(n*lags); %BBE set-up

L=favar.L;
Sigma=nspd(favar.Sigma);
if onestep==1
indexnM=favar.indexnM;
end
XZ0mean=favar.XZ0mean;
XZ0var=favar.XZ0var;
favar_X=favar.X;
% load priors
L0=favar.L0*eye(n);
a0=favar.a0;
b0=favar.b0;
sigmahat=(1/T)*(EPS'*EPS);

% preallocation
beta_gibbs=zeros(size(B(:),1),It-Bu);
sigma_gibbs=zeros(size(sigmahat(:),1),It-Bu);
% X_gibbs=zeros(size(X(:),1),It-Bu);
% Y_gibbs=zeros(size(Y(:),1),It-Bu);
% FY_gibbs=zeros(size(data_endo(:),1),It-Bu);
L_gibbs=zeros(size(L(:),1),It-Bu);
R2_gibbs=zeros(size(favarX,2),It-Bu);

if onestep==0 %static factors in this case
    FY=data_endo;
    pbstring='two-step'; %string for the progress bar
elseif onestep==1
    pbstring='one-step'; %string for the progress bar
end

% state-space representation
if onestep==1
B_ss=[B';eye(n*(lags-1)) zeros(n*(lags-1),n)];
sigma_ss=[sigmahat zeros(n,n*(lags-1));zeros(n*(lags-1),n*lags)];
end

% create a progress bar
hbar = parfor_progressbar(It,['Progress of the Gibbs sampler (',pbstring,').']);

%% start iterations
for ii=1:It
    if onestep==1
        % Sample latent factors using Carter and Kohn (1994)
        FY=favar_kfgibbsnv(XY,XZ0mean,XZ0var,L,Sigma,B_ss,sigma_ss,indexnM);
        % demean generated factors
        FY=favar_demean(FY);
        % Sample autoregressive coefficients B,in the twostep procedure FY is static, and we want to use updated B
        [B,~,~,X,~,Y]=olsvar(FY,data_exo,const,lags);
        [arvar]=arloop(FY,const,p,n);
    end
    
   % set 'prior' values (here, the dummy observations)
   [Y,X,Tstar]=doprior(Y,X,n,m,p,Tstar,ar,arvar,lambda1,lambda3,lambda4,priorexo);
   % obtain posterior distribution parameters
   [Bcap,betacap,Scap,alphacap,phicap,alphatop]=dopost(X,Y,Tstar,k,n);

% draw B from a matrix-variate student distribution with location Bcap, scale Scap and phicap and degrees of freedom alphatop
stationary=0;
while stationary==0
B=matrixtdraw(Bcap,Scap,phicap,alphatop,k,n);
   [stationary]=checkstable(B(:),n,lags,size(B,1)); %switches stationary to 0, if the draw is not stationary
end
if onestep==1
B_ss(1:n,:)=B';
end

% then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
sigma=iwdraw(Scap,alphacap);
if onestep==1
sigma_ss(1:n,1:n)=sigma;
end

%% Sample Sigma and L
[Sigma,L]=favar_SigmaL(Sigma,L,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,lags,L0);

%% record the values if the number of burn-in iterations is exceeded
if ii>Bu
% values of vector beta
beta_gibbs(:,ii-Bu)=B(:);
% values of sigma (in vectorized form)
sigma_gibbs(:,ii-Bu)=sigma(:);

% save the factors and loadings
X_gibbs(:,ii-Bu)=X(:);
Y_gibbs(:,ii-Bu)=Y(:);
FY_gibbs(:,ii-Bu)=FY(:);
L_gibbs(:,ii-Bu)=L(:);

% compute R2 (Coefficient of Determination) for plotX variables (can be done after burn-in)
R2=favar_R2(favarX,FY);
R2_gibbs(:,ii-Bu)=R2(:);

% compute posterior estimates, this is different here to the other prior 
[beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=doestimates(betacap,phicap,Scap,alphacap,alphatop,n,k,cband);
beta_median_gibbs(:,:,ii-Bu)=beta_median;
B_median_gibbs(:,:,ii-Bu)=B_median;
beta_std_gibbs(:,:,ii-Bu)=beta_std;
beta_lbound_gibbs(:,:,ii-Bu)=beta_lbound;
beta_ubound_gibbs(:,:,ii-Bu)=beta_ubound;
sigma_median_gibbs(:,:,ii-Bu)=sigma_median;
% if current iteration is still a burn iteration, do not record the result
else
end

% update progress by one iteration
hbar.iterate(1);

% go for next iteration
end

% in case we have thinning of the draws,
thin=abs(round(favar.thin)); % should be a positive integer
if thin~=1
    beta_gibbs=beta_gibbs(:,thin:thin:end);
    sigma_gibbs=sigma_gibbs(:,thin:thin:end);
    X_gibbs=X_gibbs(:,thin:thin:end);
    Y_gibbs=Y_gibbs(:,thin:thin:end);
    FY_gibbs=FY_gibbs(:,thin:thin:end);
    L_gibbs=L_gibbs(:,thin:thin:end);
    R2_gibbs=R2_gibbs(:,thin:thin:end);
    It=(1/thin)*It;
    Bu=(1/thin)*Bu;
end

% save in favar structure
favar.X_gibbs=X_gibbs;
favar.Y_gibbs=Y_gibbs;
favar.FY_gibbs=FY_gibbs;
favar.L_gibbs=L_gibbs;
favar.R2_gibbs=R2_gibbs;


favar.beta_median_gibbs=beta_median_gibbs;
favar.B_median_gibbs=B_median_gibbs;
favar.beta_std_gibbs=beta_std_gibbs;
favar.beta_lbound_gibbs=beta_lbound_gibbs;
favar.beta_ubound_gibbs=beta_ubound_gibbs;
favar.sigma_median_gibbs=sigma_median_gibbs;

% close progress bar
close(hbar);

