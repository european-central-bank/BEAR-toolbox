function [beta_gibbs, sigma_gibbs] =...
    get_draws(data_endo,data_exo, opts)

[Bhat, betahat, sigmahat, Xstar, Xbar, Ystar, ystar, EPS, eps, n, m, p, Tstar, k, q]=...
    bear.olsvar(data_endo,data_exo,opts.const,opts.lags);
%variance from univariate OLS for priors
[arvar] = bear.arloop(Ystar,opts.const,p,n);

%create a vector for AR hyperparamters
ar = ones(n,1)*opts.user_ar;

% individual priors 0 for default
for ii=1:n
    for jj=1:m
        tmp(ii,jj) = opts.lambda4;
        priorexo(ii,jj) = opts.priorsexogenous;
    end
end
opts.lambda4 = tmp;

blockexo = [];

[beta0,omega0,sigma]=bear.mprior(ar,arvar,sigmahat,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,n,m,p,k,q,opts.prior,opts.bex,blockexo,priorexo);
[betabar,omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
[beta_gibbs,sigma_gibbs]=bear.mgibbs(opts.It,opts.Bu,betabar,omegabar,sigma,q);