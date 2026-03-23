
%% Loading data
data_endo_table = readtable("+nw_favar/data_endo_a.csv");
data_exo_p = readmatrix("+nw_favar/data_exo_p.csv");
beta_gibbs = readmatrix("+nw_favar/beta_gibbs.csv");
sigma_gibbs = readmatrix("+nw_favar/sigma_gibbs.csv");
favar.FY_gibbs = readmatrix("+nw_favar/FY_gibbs.csv");
favar.X = readmatrix("+nw_favar/X.csv");
%% Setting up opt structure
fileName = "+nw_favar/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

favar.FAVAR = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[forecast_record,forecast_estimates]= nw_favar.run_forecast(data_endo_table, data_exo_p, beta_gibbs, sigma_gibbs, opt,favar);