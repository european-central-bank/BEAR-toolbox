function [beta_gibbs, sigma_gibbs] = get_draws(data_endo,data_exo, opt)


    [Bhat, betahat, sigmahat, Xstar, Xbar, Ystar, ystar, EPS, eps, n, m, p, Tstar, k, q]=bear.olsvar(data_endo,data_exo,opt.const,opt.lags);
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
            tmp(ii,jj) = opt.lambda4;
        end
    end

    opt.lambda4 = tmp;

    blockexo = [];
    if  opt.bex==1
        [blockexo]=bear.loadbex(endo,pref);
    end
    %create a vector for AR hyperparamters
    ar = ones(n,1)*opt.user_ar;

    %variance from univariate OLS for priors
    [arvar] = bear.arloop(Ystar,opt.const,p,n);
    
    ystar = Ystar(:);

% [Ystar, ystar, Xstar, Tstar, Ydum, ydum, Xdum, Tdum] = ...
%     bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,opt.const,opt.lambda6,opt.lambda7,opt.lambda8,opt.scoeff,opt.iobs,opt.lrp,H);

% setting up prior
[beta0, omega0]=bear.ndprior(ar,arvar,opt.lambda1,opt.lambda2,opt.lambda3,opt.lambda4,opt.lambda5,n,m,p,k,q,opt.bex,blockexo,priorexo);

% obtain posterior distribution parameters
[beta_gibbs,sigma_gibbs]=bear.ndgibbs(opt.It,opt.Bu,beta0,omega0,Xstar,Ystar,ystar,Bhat,n,Tstar,q);

%[beta_median, beta_std, beta_lbound, beta_ubound,sigma_median]=bear.ndestimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
end