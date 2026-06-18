function [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, Yi, Xi, beta_gibbs,sigma_gibbs, N,n,m,p,k,T,q] = driver_estimation_panel_random_eff(data_endo,data_exo,const,lags,lambda1,It,Bu,cband)

    % compute preliminary elements
    [Xi, Xibar, Xbar, Yi, yi, y, N, n, m, p, T, k, q, h]=bear.panel3prelim(data_endo,data_exo,const,lags);

    % obtain prior elements
    [b, bbar, sigeps]=bear.panel3prior(Xibar,Xbar,yi,y,N,q);

    % compute posterior distribution parameters
    [omegabarb, betabar]=bear.panel3post(h,Xbar,y,lambda1,bbar,sigeps);

    % run the Gibbs sampler
    [beta_gibbs, sigma_gibbs]=bear.panel3gibbs(It,Bu,betabar,omegabarb,sigeps,h,N,n,q);
    
    % compute posterior estimates
    [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.panel3estimates(N,n,q,betabar,omegabarb,sigeps,cband);
end