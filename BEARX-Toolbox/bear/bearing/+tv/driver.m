%%This piece of package is an extract of the estimation oand forecast of genric Time varying model i.e timevarying parameters and stds (TV2 in BEAR)
%% Loading data
data_endo_table = readtable("+tv/data_endo.csv");
data_exo = readmatrix("+tv/data_exo.csv");

% load("data.mat")
%% Setting up opt structure
fileName = "+tv/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs,beta_gibbs_in, omega_gibbs,sigma_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs_in, lambda_t_gibbs ,sigma_t_gibbs, sbar, forecast_record] = ...
    tv.get_draws_and_forecast(data_endo_table, data_exo, opt);

