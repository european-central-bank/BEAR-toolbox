%% Loading data

beta_gibbs = readmatrix("+nw/beta_gibbs.csv");
sigma_gibbs = readmatrix("+nw/sigma_gibbs.csv");
Y = readmatrix("+nw/Y.csv");
X = readmatrix("+nw/X.csv");
%% Setting up opt structure
fileName = "+nw/opts.json"; % filename in JSON extension.
str      = fileread(fileName); % dedicated for reading files as text.
opt      = jsondecode(str);

favar.FAVAR = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws
[strshocks_estimates,irf_estimates,D_estimates,gamma_estimates,favar]= ...
    nw.run_irf_triang(Y,X,beta_gibbs, sigma_gibbs, opt,favar);