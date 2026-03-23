function [bhat, sigmahatb, sigmahat, Y, X, N,n,m,p,k,q,T] = driver_estimation_panel_ols(data_endo,data_exo,const,lags)

    % compute preliminary elements
    [X, Y, N, n, m, p, T, k, q]=bear.panel1prelim(data_endo,data_exo,const,lags);
    % obtain the estimates for the model
    [bhat, sigmahatb, sigmahat]=bear.panel1estimates(X,Y,N,n,q,k,T);
end