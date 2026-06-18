
%% Loading data
data_endo_table = readtable("+sv/data_endo.csv");
data_exo = readmatrix("+sv/data_exo.csv");

% load("data.mat")
%% Setting up opt structure
fileName = "+sv/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs,sigma_gibbs, F_gibbs, L_gibbs, gamma_gibbs, phi_gibbs, sigma_gibbs_in, lambda_t_gibbs ,sigma_t_gibbs, sbar, forecast_record] = ...
    sv.get_draws_and_forecast(data_endo_table, data_exo, opt);

