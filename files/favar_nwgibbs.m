function [beta_gibbs,sigma_gibbs,favar,It,Bu]=favar_nwgibbs(It,Bu,Bhat,EPS,n,m,p,k,T,q,lags,data_endo,ar,arvar,lambda1,lambda3,lambda4,prior,priorexo,const,data_exo,favar,Y,X)

%% references: Bernanke, Boivin, Eliasz (2005), Koop & Korobilis

% function [beta_gibbs sigma_gibbs]=nwgibbs(It,Bu,Bbar,phibar,alphatilde,Sbar,alphabar,n,k)
% performs the Gibbs algortihm 2.1.3 for the normal-Wishart prior, and returns draws from posterior distribution
% inputs:  - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix 'Bbar': posterior matrix of VAR coefficients for the normal-Wishart prior (defined in 1.4.17)
%          - matrix 'phibar':posterior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.16)
%          - matrix 'Sbar': posterior scale matrix for sigma (defined in 1.4.19)
%          - integer 'alphabar': posterior degrees of freedom for sigma (defined in 1.4.18)
%          - integer 'alphatilde': degrees of freedom of the matrix student distribution (defined in 1.4.23)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)

%% preliminary tasks
% initialise variables
nfactorvar=favar.nfactorvar;
numpc=favar.numpc;
favarX=favar.X(:,favar.plotX_index);
favarplotX_index=favar.plotX_index;
onestep=favar.onestep;
% initial conditions XZ0~N(XZ0mean,XZ0var)
favar.XZ0mean=zeros(n*lags,1);
favar.XZ0var=favar.L0*eye(n*lags); %BBE set-up

XY=favar.XY;
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
beta_gibbs=zeros(size(Bhat(:),1),It-Bu);
sigma_gibbs=zeros(size(sigmahat(:),1),It-Bu);
X_gibbs=zeros(size(X(:),1),It-Bu);
Y_gibbs=zeros(size(Y(:),1),It-Bu);
FY_gibbs=zeros(size(data_endo(:),1),It-Bu);
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
    B_ss=[Bhat';eye(n*(lags-1)) zeros(n*(lags-1),n)];
    sigma_ss=[sigmahat zeros(n,n*(lags-1));zeros(n*(lags-1),n*lags)];
elseif onestep==0
    % set prior values
    [B0,~,phi0,S0,alpha0]=nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
    % obtain posterior distribution parameters
    [Bbar,~,phibar,Sbar,alphabar,alphatilde]=nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k);
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
        % Sample autoregressive coefficients B
        [~,~,~,X,~,Y]=olsvar(FY,data_exo,const,lags);
        [arvar]=arloop(FY,const,p,n);
        % set prior values, new with every iteration for onestep only
        [B0,~,phi0,S0,alpha0]=nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
        % obtain posterior distribution parameters, new with every iteration for onestep only
        [Bbar,~,phibar,Sbar,alphabar,alphatilde]=nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k);
    end
    
    % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
    stationary=0;
    while stationary==0
        B=matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);
        [stationary]=checkstable(B(:),n,lags,size(B,1)); %switches stationary to 0, if the draw is not stationary
    end
    
    if onestep==1
        B_ss(1:n,:)=B';
    end
    
    % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
    sigma=iwdraw(Sbar,alphabar);
    
    if onestep==1
        sigma_ss(1:n,1:n)=sigma;
        % Sample Sigma and L
        [Sigma,L]=favar_SigmaL(Sigma,L,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,lags,L0);
    end
    
    
    
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
        
        % compute R2 (Coefficient of Determination) for plotX variables
        R2=favar_R2(favarX,FY,L,favarplotX_index);
        R2_gibbs(:,ii-Bu)=R2(:);
        
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

% close progress bar
close(hbar);

