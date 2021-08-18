function [B0 beta0 phi0 S0 alpha0]=panel2prior(N,n,m,p,T,k,q,data_endo,ar,lambda1,lambda3,lambda4,priorexo)



% first obtain the residual variance of individual (pooled) autoregressive models
[arvar]=bear.panelarloop(n,N,p,T,data_endo);

% then obtain prior elements (using a normal-Wishart prior)
[B0 beta0 phi0 S0 alpha0]=bear.nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,21,priorexo);


















