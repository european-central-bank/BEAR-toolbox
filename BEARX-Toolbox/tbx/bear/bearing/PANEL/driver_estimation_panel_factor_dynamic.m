function [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,Ymat,y, Xtilde,theta_gibbs,sigma_gibbs,sigmatilde_gibbs,Zeta_gibbs,phi_gibbs,B_gibbs,Xi,thetabar,N,n,m,p,T,d,k,q,d1,d2,d3,d4,d5,acceptrate] = driver_estimation_panel_factor_dynamic(data_endo,data_exo,const,lags,It,Bu,cband,alpha0,delta0,pick,pickf,rho,gamma,a0,b0,psi)

    % compute preliminary elements
    [Ymat,Xmat,N,n,m,p,T,k,q,h]=bear.panel6prelim(data_endo,data_exo,const,lags);

    % obtain prior elements
    [d1,d2,d3,d4,d5,d,Xi1,Xi2,Xi3,Xi4,Xi5,Xi,y,Xtilde,thetabar,theta0,H,Thetatilde,Theta0,G]=bear.panel6prior(N,n,p,m,k,q,h,T,Ymat,Xmat,rho,gamma);

    % run the Gibbs sampler
    [theta_gibbs,sigmatilde_gibbs,Zeta_gibbs,sigma_gibbs,phi_gibbs,B_gibbs,acceptrate]=bear.panel6gibbs(y,Xtilde,N,n,T,theta0,Theta0,thetabar,alpha0,delta0,a0,b0,psi,d1,d2,d3,d4,d5,d,It,Bu,H,G,pick,pickf,gamma);

    % compute posterior estimates
    [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median]=bear.panel6estimates(d,N,n,T,theta_gibbs,sigma_gibbs,cband);
end