if stvol==4
    const=0; %set const to 0 if the model is a local mean model
end

[Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
[arvar]=bear.arloop(data_endo,const,p,n);
[yt, Xt, Xbart]=bear.stvoltmat(Y,X,n,T);