function [beta_median, B_median, beta_std, beta_lbound, beta_ubound, sigma_median, Ymat,Xmat,beta_gibbs,sigma_gibbs,N,n,m,p,k,T,Y,X,q] = driver_estimation_panel_bayesian(data_endo,data_exo,const,lags,Units,ar,lambda1,lambda3,lambda4,It,Bu,priorexo,cband)

    % compute preliminary elements
    [X, Xmat, Y, Ymat, N, n, m, p, T, k, q]=bear.panel2prelim(data_endo,data_exo,const,lags,Units);

    % obtain prior elements (from a standard normal-Wishart)
    [B0, beta0, phi0, S0, alpha0]=bear.panel2prior(N,n,m,p,T,k,q,data_endo,ar,lambda1,lambda3,lambda4,priorexo);

    % obtain posterior distribution parameters
    [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,N*T,k);

    % run the Gibbs sampler
    [beta_gibbs, sigma_gibbs]=bear.nwgibbs(It,Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);

    % compute posterior estimates
    [beta_median, B_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband);
    
end