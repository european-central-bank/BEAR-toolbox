
%% Loading data
data_endo_table = readtable("+mp/data_endo_a.csv"); %referring to same csv in different folder
data_exo_p = readmatrix("+nd/data_exo_p.csv");
beta_gibbs = readmatrix("+nd/beta_gibbs.csv");
sigma_gibbs = readmatrix("+nd/sigma_gibbs.csv");

%% Setting up opt structure
fileName = "+nd/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

favar.FAVAR = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[forecast_record,forecast_estimates]= nd.run_forecast(data_endo_table, data_exo_p, beta_gibbs, sigma_gibbs, opt,favar);