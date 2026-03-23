function [sample, fv]=favar_nwsampler(It,n,m,p,k,T,q,ar,lambda1,lambda3,lambda4,prior,priorexo,const,data_exo,favar,Y,X,prep)
    
    favarX           = favar.X(:,favar.plotX_index); 
    favarplotX_index = favar.plotX_index; 
    onestep          = favar.onestep; 
    XZ0mean          = zeros(n*p,1);            
    XZ0var           = favar.L0*eye(n*p);
    XY               = favar.XY; 
    L                = favar.L;
    Sigma            = bear.nspd(favar.Sigma);
    favar_X          = favar.X;
    nfactorvar       = favar.nfactorvar;
    numpc            = favar.numpc;

    L0               = favar.L0;
    a0               = favar.a0; 
    b0               = favar.b0;

    B_ss             = prep.B_ss;
    sigma_ss         = prep.sigma_ss;

    FY               = prep.FY;
    Bbar             = prep.Bbar;
    phibar           = prep.phibar;
    Sbar             = prep.Sbar;
    alphabar         = prep.alphabar;  
    alphatilde       = prep.alphatilde;

    beta_gibbs = zeros(size(Bbar(:),1),It);
    sigma_gibbs = zeros(size(Sbar(:),1),It);
    X_gibbs = zeros(size(X(:),1),It);
    Y_gibbs = zeros(size(Y(:),1),It);
    FY_gibbs = zeros(size(prep.FY(:),1),It);
    L_gibbs = zeros(size(L(:),1),It);
    R2_gibbs = zeros(size(favarX,2),It);

    for ii = 1:It
        [sample, fv] = smplr();
    end


function [sample, fv] = smplr()

    if onestep==1
        % Sample latent factors using Carter and Kohn (1994)
        FY=bear.favar_kfgibbsnv(XY,XZ0mean,XZ0var,L,Sigma,B_ss,sigma_ss,indexnM);
        % demean generated factors
        FY=bear.favar_demean(FY);
        % Sample autoregressive coefficients B
        [~,~,~,X,~,Y]=bear.olsvar(FY,data_exo,const,p);
        [arvar]=bear.arloop(FY,const,p,n);
        % set prior values, new with every iteration for onestep only
        [B0,~,phi0,S0,alpha0]=bear.nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
        % obtain posterior distribution parameters, new with every iteration for onestep only
        [Bbar,~,phibar,Sbar,alphabar,alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,T,k);
    end
    
    % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
    stationary=0;
    while stationary==0
        B=bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);
        [stationary]=bear.checkstable(B(:),n,p,size(B,1)); %switches stationary to 0, if the draw is not stationary
    end
    
    if onestep==1
        B_ss(1:n,:)=B';
    end
    
    % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
    sigma=bear.iwdraw(Sbar,alphabar);
    
    if onestep==1
        sigma_ss(1:n,1:n)=sigma;
        % Sample Sigma and L
        [Sigma,L]=bear.favar_SigmaL(Sigma,L,nfactorvar,numpc,onestep,n,favar_X,FY,a0,b0,T,p,L0);
    end
    
        % values of vector beta
        beta_gibbs(:,end+1)=B(:);
        % values of sigma (in vectorized form)
        sigma_gibbs(:,end+1)=sigma(:);
        
        % save the factors and loadings
        X_gibbs(:,end+1)=X(:);
        Y_gibbs(:,end+1)=Y(:);
        FY_gibbs(:,end+1)=FY(:);
        L_gibbs(:,end+1)=L(:);
        
        % compute R2 (Coefficient of Determination) for plotX variables
        R2=bear.favar_R2(favarX,FY,L,favarplotX_index);
        R2_gibbs(:,end+1)=R2(:);
        
        % save in favar structure
        fv.X_gibbs  = X_gibbs;
        fv.Y_gibbs  = Y_gibbs;
        fv.FY_gibbs = FY_gibbs;
        fv.L_gibbs  = L_gibbs;
        fv.R2_gibbs = R2_gibbs;
        
        
        sample.beta_gibbs = beta_gibbs;
        sample.sigma_gibbs = sigma_gibbs;
end

end