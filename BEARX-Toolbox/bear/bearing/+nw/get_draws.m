function [beta_gibbs, sigma_gibbs] = get_NW_draws(Ystar, Xstar, opt)

    %get size of the matrices
    [Tstar, n] = size(Ystar);
    [~ , k] = size(Xstar);
    q = n*k;
    p = opt.lags;
    m = k - n*p;

    % individual priors 0 for default
    for ii=1:n
        for jj=1:m
            priorexo(ii,jj) = opt.priorsexogenous;
        end
    end

    %create a vector for AR hyperparamters
    ar = ones(n,1)*opt.user_ar;


    %variance from univariate OLS for priors
    [arvar] = bear.arloop(Ystar,opt.const,p,n);

    %setting up prior
    [B0,beta0,phi0,S0,alpha0] = bear.nwprior(ar,arvar,opt.lambda1,opt.lambda3,opt.lambda4,n,m,p,k,q,...
        opt.prior,priorexo);
    % obtain posterior distribution parameters
    [Bbar,betabar,phibar,Sbar,alphabar,alphatilde] = bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
    [beta_gibbs,sigma_gibbs] = bear.nwgibbs(opt.It,opt.Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);

end

