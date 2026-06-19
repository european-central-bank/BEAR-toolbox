function [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,Y,Ymat,Xmat,Xdot,theta_gibbs,sigma_gibbs,Xi,N,n,m,p,k,T,q,d1,d2,d3,d4,d5] = driver_estimation_panel_factor_static(data_endo,data_exo,const,lags,It,Bu,cband,alpha0,delta0,pick,pickf)

    % compute preliminary elements
    [Ymat, Xmat, N, n, m, p, T, k, q, h]=bear.panel5prelim(data_endo,data_exo,const,lags);

    % Xmat dimension (Tx(Nnp+m))
    % Y = X*B
    % X = kron(speye(9),(Xmat))
    % B = Xi*theta
    % obtain prior elements
    [d1, d2, d3, d4, d5, d, Xi1, Xi2, Xi3, Xi4, Xi5, Xi, Y, y, Xtilde, Xdot, theta0, Theta0]=bear.panel5prior(N,n,p,m,k,q,h,T,Ymat,Xmat);

    % run the Gibbs sampler
    [theta_gibbs,sigma_gibbs,sigmatilde_gibbs,sig_gibbs]=bear.panel5gibbs(y,Y,Xtilde,Xdot,N,n,T,d,theta0,Theta0,alpha0,delta0,It,Bu,pick,pickf);

    % compute posterior estimates
    [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median]=bear.panel5estimates(d,N,n,theta_gibbs,sigma_gibbs,cband);
end