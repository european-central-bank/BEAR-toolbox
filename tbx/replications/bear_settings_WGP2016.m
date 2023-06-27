function s = bear_settings_WGP2016
%% extended replication of Wieladek & Garcia Pascual (2016): The European Central Bank's QE: A New Hope
% who lend the approach from Weale & Wieladek (2016): What are the macroeconomic effects of asset purchases?
% extended sample from 2014m5 to 2018m12, identification schemes I, II, III
% data set additionally includes several series to assess potential transmission channels and country specific effects (DE, FR, IT)
% extended by Marius Schulte (mail@mbschulte.com)

% general data and model information

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
s = BEARsettings(2, 'ExcelFile', fullfile(bearroot(), 'replications','data_WGP2016.xlsx') );

% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=3;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='2014m5';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2018m12';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='hicp gdp app 10y stockindex';
% exogenous variables, if any; must be a single string, with variable names separated by a space
s.varexo='';
% number of lags
s.lags=2;
% inclusion of a constant (1=yes, 0=no)
s.const=1;

% excel results file name
s.results_sub='results_WGP2016';
s.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
% to output results in excel
s.results=1;
% output charts
s.plot=1;
% save matlab workspace (1=yes, 0=no (standard))
s.workspace=0;

% FAVAR options
s.favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)

% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
% 61=Mean-adjusted
s.prior=41;
% hyperparameter: autoregressive coefficient
s.ar=0.8; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
% switch to Excel interface
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
s.lambda1=1000; % quasi-flat (diffuse) normal-wishart prior here, in the spirit of Uhlig (2005)
% hyperparameter: lambda2
s.lambda2=0.5;
% hyperparameter: lambda3
s.lambda3=1;
% hyperparameter: lambda4
s.lambda4=1;
% hyperparameter: lambda5
s.lambda5=0.001;
% hyperparameter: lambda6
s.lambda6=1;
% hyperparameter: lambda7
s.lambda7=0.1;
% Overall tightness on the long run prior
s.lambda8=1;
% total number of iterations for the Gibbs sampler
s.It=5000;
% number of burn-in iterations for the Gibbs sampler
s.Bu=1000;
% hyperparameter optimisation by grid search (1=yes, 0=no)
s.hogs=0;
% block exogeneity (1=yes, 0=no)
s.bex=0;
% sum-of-coefficients application (1=yes, 0=no)
s.scoeff=0;
% dummy initial observation application (1=yes, 0=no)
s.iobs=0;
% Long run prior option
s.lrp=0;
% create H matrix for the long run priors
% now taken from excel loadH.m
% H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
% (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
s.priorf=100;

% Model options

% activate impulse response functions (1=yes, 0=no)
s.IRF=1;
% number of periods for impulse response functions
s.IRFperiods=36;
% activate unconditional forecasts (1=yes, 0=no)
s.F=0;
% activate forecast error variance decomposition (1=yes, 0=no)
s.FEVD=0;
% activate historical decomposition (1=yes, 0=no)
s.HD=0; s.HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
% activate conditional forecasts (1=yes, 0=no)
s.CF=0;
% structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
%                            5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
s.IRFt=4;
% IRFt options
% strctident settings for OLS model


s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
% Correlation restriction options:
s.strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
s.strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"

% activate forecast evaluation (1=yes, 0=no)
s.Feval=0;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
s.CFt=1;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
s.Fstartdate='2014q1';
% end date for forecasts
s.Fenddate='2016q4';
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
s.Fendsmpl=0;
% step ahead evaluation
s.hstep=1;
% window_size for iterative forecasting 0 if no iterative forecasting
s.window_size=0;
% evaluation_size as percent of window_size                                      <                                                                                    -
s.evaluation_size=0.5;
% confidence/credibility level for VAR coefficients
s.cband=0.95;
% confidence/credibility level for impusle response functions
s.IRFband=0.68;
% confidence/credibility level for forecasts
s.Fband=0.68;
% confidence/credibility level for forecast error variance decomposition
s.FEVDband=0.68;
% confidence/credibility level for historical decomposition
s.HDband=0.68;