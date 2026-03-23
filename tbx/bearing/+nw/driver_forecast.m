
%% Loading data
data_endo_table = readtable("+nw/data_endo_a.csv");
data_exo_p = readmatrix("+nw/data_exo_p.csv");
beta_gibbs = readmatrix("+nw/beta_gibbs.csv");
sigma_gibbs = readmatrix("+nw/sigma_gibbs.csv");

%% Setting up opt structure
fileName = "+nw/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

favar.FAVAR = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[forecast_record,forecast_estimates]= nw.run_forecast(data_endo_table, data_exo_p, beta_gibbs, sigma_gibbs, opt,favar);