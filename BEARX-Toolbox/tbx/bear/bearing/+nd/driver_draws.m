
%% Loading data
data_endo = readmatrix("+nd/data_endo.csv");
data_exo = readmatrix("+nd/data_exo_p.csv");

% load("data.mat")
%% Setting up opt structure
fileName = "+nd/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs, sigma_gibbs] = nd.get_draws(data_endo, data_exo, opt);