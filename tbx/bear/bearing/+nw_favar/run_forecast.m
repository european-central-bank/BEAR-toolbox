function [forecast_record,forecast_estimates] = run_forecast(data_endo_table, data_exo_p, ....
    beta_gibbs, sigma_gibbs,opts, favar)

data_endo_a = table2array(data_endo_table(:,2:end));
dates       = table2array(data_endo_table(:,1));

%get size of the matrices
[~, n]     = size(data_endo_a);
[q , ~]    = size(beta_gibbs);
k = q/n;

%% BLOCK 5: FORECASTS

[Fstartlocation, Fperiods] = nw.get_fcast_rng(dates,opts);

[forecast_record] = bear.forecast(data_endo_a,data_exo_p,opts.It,opts.Bu,beta_gibbs,sigma_gibbs,Fperiods,n,opts.lags,k,opts.const,...
    Fstartlocation,favar);
% compute posterior estimates
[forecast_estimates] = bear.festimates(forecast_record,n,Fperiods,opts.Fband);
 
    