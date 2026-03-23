function [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median,Yi,Xi,beta_gibbs,sigma_gibbs,N,n,m,p,k,T,q] = driver_estimation_panel_random_eff_hier(data_endo,data_exo,const,lags,lambda2,lambda3,lambda4,It,Bu,cband,s0,v0,pick,pickf)

    % compute preliminary elements
    [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel4prelim(data_endo,data_exo,const,lags);
    % obtain prior elements
    [omegab]=bear.panel4prior(N,n,m,p,T,k,data_endo,q,lambda3,lambda2,lambda4);
    % run the Gibbs sampler
    [beta_gibbs,sigma_gibbs]=bear.panel4gibbs(N,n,h,T,k,q,Yi,Xi,s0,omegab,v0,It,Bu,pick,pickf);
    % compute posterior estimates
    [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.panel4estimates(N,n,q,beta_gibbs,sigma_gibbs,cband,[],[]); % beta_mean,sigma_mean
end