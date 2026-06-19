
%% Loading data
data_endo = readmatrix("data_endo.csv");
% data_exo = readmatrix("+nw_dummy/data_exo.csv");
data_exo = [];

% load("data.mat")
%% Setting up opt structure
fileName = "+nw_dummy/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[beta_gibbs, sigma_gibbs] = nw_dummy.get_draws(data_endo, data_exo, opt);

