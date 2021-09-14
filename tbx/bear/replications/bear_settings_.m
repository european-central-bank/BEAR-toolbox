function s = bear_settings_
% The default data set

% general data and model information

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
s = BEARsettings(2, 'ExcelPath', fullfile(bearroot(), 'replications','data_.xlsx') );
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=2;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='1974q1';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2014q4';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='DOM_GDP DOM_CPI STN';
% exogenous variables, if any; must be a single string, with variable names separated by a space
s.varexo='';
% number of lags
s.lags=4;
% inclusion of a constant (1=yes, 0=no)
s.const=1;
% path to data
s.pref.datapath=bearroot(); % fileparts(mfilename('fullpath')); % next to settings
% excel results file name
s.pref.results_sub='results_bvr';
s.pref.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
% to output results in excel
s.pref.results=1;
% output charts
s.pref.plot=1;
% pref: useless by itself, just here to avoid code to crash
s.pref.pref=0;
% save matlab workspace (1=yes, 0=no (default))
s.pref.workspace=0;

% FAVAR options
s.favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)

% BVAR specific information: will be read only if VARtype=2

% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
% 61=Mean-adjusted
s.prior=12;
% hyperparameter: autoregressive coefficient
s.ar=0.8;
% switch to Excel interface
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
s.lambda1=0.1;
% hyperparameter: lambda2
s.lambda2=0.5;
% hyperparameter: lambda3
s.lambda3=1;
% hyperparameter: lambda4
s.lambda4=100;
% hyperparameter: lambda5
s.lambda5=0.001;
% hyperparameter: lambda6
s.lambda6=1;
% hyperparameter: lambda7
s.lambda7=0.1;
% Overall tightness on the long run prior
s.lambda8=1;
% (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
s.priorf=100;
% total number of iterations for the Gibbs sampler
s.It=2000;
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

% Model options
% activate impulse response functions (1=yes, 0=no)
s.IRF=1;
% activate unconditional forecasts (1=yes, 0=no)
s.F=1;
% activate forecast error variance decomposition (1=yes, 0=no)
s.FEVD=1;
% activate historical decomposition (1=yes, 0=no)
s.HD=0;
% activate conditional forecasts (1=yes, 0=no)
s.CF=1;
% structural identification (1=none, 2=Choleski, 3=triangular factorisation, 4=sign restrictions)
s.IRFt=4;
% IRFt options
% strctident settings for OLS model
s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
% Correlation restriction options:
s.strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
s.strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"

% activate forecast evaluation (1=yes, 0=no)
s.Feval=1;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
s.CFt=1;
% number of periods for impulse response functions
s.IRFperiods=20;
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
s.IRFband=0.95;
% confidence/credibility level for forecasts
s.Fband=0.95;
% confidence/credibility level for forecast error variance decomposition
s.FEVDband=0.95;
% confidence/credibility level for historical decomposition
s.HDband=0.95;