function [irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs]...
    =IRFt6_Bayesian(betahat,IRFperiods,n,m,p,k,T,names,startdate,enddate,X,FEVDresperiods,Y,pref,IRFt,arvar,q,It,Bu,lambda1,lambda3,lambda4,strctident,favar)

%%Implementation of a Bayesian Proxy VAR based on the Codes published by Caldara and Herbst (2018)
%%Implementation by Ben Schumann

%% IV identification
% Load IV and make it comparable with the reduced form errors
[EPSIV,IVcut,~,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,~,cut1,cut2,cut3,cut4]=...
    loadIV(betahat,k,n,Y,X,T,p,names,startdate,enddate,strctident);
% IV routine
[beta_draws,sigma_draws,IV_draws,C_draws]=...
    irfIV_MH(EPSIV,IVcut,betahat,sigmahatIV,sigma_hat,inv_sigma_hat,IV,txt,cut1,cut2,cut3,cut4,names,It,Bu,n,arvar,lambda1,lambda3,lambda4,m,p,k,q,X,Y,T,startdate,enddate,pref,strctident,IRFperiods,IRFt);

%reorganize
%finaly tell bear how many draws we stored
It=size(IV_draws,2);
Bu=0; %set burn in to 0, as burn in is no longer requiered

%% check Restrictions
[irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs]...
        =irfres(beta_draws,sigma_draws,C_draws,IV_draws,IRFperiods,n,m,p,k,T,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);
    
    