
%% Loading data
Y = readmatrix("+nw/Y.csv");
X = readmatrix("+nw/X.csv");

size(Y)
size(X)

% load("data.mat")
%% Setting up opt structure
str = fileread("+nw/NormalWishartEstimator.json"); % dedicated for reading files as text.
priorSettings = var.settings.NormalWishartPriorSettings();


v = reducedForm.Model( ...
    meta={"endogenous", ["DOM_GDP", "DOM_CPI", "STN"], "order", 4, "constant", true, } ...
    , priors={"NormalWishart", } ...
)

numFixedSamples = 1; 1000;
numBurnins = 1000;


%====================================================

opt = struct();
opt.priorsexogenous = priorSettings.Exogenous;
opt.user_ar = priorSettings.Autoregression;
opt.lambda1 = priorSettings.Lambda1;
opt.lambda3 = priorSettings.Lambda3;
opt.lambda4 = priorSettings.Lambda4;


sigmaAdapter = struct();
sigmaAdapter.eye = 22;
sigmaAdapter.ar = 21;

try
    opt.prior = sigmaAdapter.(lower(priorSettings.Sigma))
catch
    error("Invalid prior type")
end

%====================================================

opt.p = v.Meta.Order;
opt.const = v.Meta.HasConstant;

opt.It = numBurnins + numFixedSamples;
opt.Bu = numBurnins;


% opt.priorsexogenous = 0;
% 
% % hyperparameters
% opt.user_ar = 1;
% opt.lambda1 = 0.1;
% opt.lambda3 = 1;
% opt.lambda4 = 100;
% 
% %prior type
% opt.prior = 21; %NW, S0 as univariate AR with 
% 
% %data matrices and sizes
% opt.p          = 4; 
% opt.const      = true;
% 
% %Settings for sampling
% opt.It = 2000;
% opt.Bu = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getting the draws

[beta_gibbs, sigma_gibbs] = nw.get_draws(Y, X, opt);

