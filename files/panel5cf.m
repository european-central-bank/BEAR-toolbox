function [cforecast_record cforecast_estimates]=panel5cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,Xi,theta_gibbs,D_record,gamma_record,CFt,Fband)







% preliminary tasks in order to be able to use the cforecast function
% recover beta_gibbs from theta_gibbs
beta_gibbs=Xi*theta_gibbs;
% switch data_endo_a into a 2 dimensional matrix
data_endo_a=reshape(data_endo_a,[],N*n,1);


% then run the gibbs sampler to obtain conditional forecasts
[cforecast_record]=cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,N*n,m,p,k,q);


% obtain point estimates and credibility interval
[cforecast_estimates]=festimates(cforecast_record,N*n,Fperiods,Fband);


% reorganise to obtain a record similar to that of the unconditional forecasts
cforecast_record=reshape(cforecast_record,n,1,N);
cforecast_estimates=reshape(cforecast_estimates,n,1,N);





























