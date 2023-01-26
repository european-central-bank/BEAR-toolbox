function s = bear_settings_TVP(excelPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX version 5.1 %
%                                                                         %
% Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                         %
% Björn van Roye  (bvanroye@bloomberg.net)                                %
%                                                                         %
% Using the BEAR toolbox implies acceptance of the End User Licence       %
% Agreement and appropriate acknowledgement should be made.               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TIME-VARYING PARAMETER EXAMPLE

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying, 7=Mixed Frequency)
if nargin < 1
    s = BEARsettings(6);
else
    s = BEARsettings(6, 'ExcelFile', excelPath);
end

%% General data and model information
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=2;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='1970q2';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2020q1';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='YER HICSA STN'; %
% exogenous variables; must be a single string, with variable names separated by a space
s.varexo='';
% number of lags
s.lags=4;
% inclusion of a constant (1=yes, 0=no)
s.const=0;
% excel results file name
s.results_sub='results_TVP';
s.results_path = fullfile(pwd,'results');
% to output results in excel
s.results=1;
% output charts
s.plot=1;
% save matlab workspace (1=yes, 0=no)
s.workspace=1;

% choice of time-varying BVAR model 
% 1=time-varying coefficients, 2=general time-varying
s.tvbvar=2;

% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
s.pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
s.pickf=5;


% calculate IRFs for every sample period (1=yes, 0=no)
s.alltirf=1;
% hyperparameter: gama
s.gamma=0.85;
% hyperparameter: alpha0
s.alpha0=0.001;
% hyperparameter: delta0
s.delta0=0.001;

% block exogeneity (1=yes, 0=no)
%s.bex=0;
% total number of iterations for the Gibbs sampler
s.It=2000;
% number of burn-in iterations for the Gibbs sampler
s.Bu=1000;

% hyperparameter: lambda4
s.lambda4=100;
% hyperparameter: gamma
s.gamma=1;
% hyperparameter: autoregressive coefficient
s.ar=0;
% switch to Excel interface
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default

% Model options

% activate impulse response functions (1=yes, 0=no)
s.IRF=1;
% number of periods for impulse response functions
s.IRFperiods=20;
% activate unconditional forecasts (1=yes, 0=no)
s.F=1;
% activate forecast error variance decomposition (1=yes, 0=no)
s.FEVD=0;
% activate historical decomposition (1=yes, 0=no)
s.HD=1;
s.HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
% activate conditional forecasts (1=yes, 0=no)
s.CF=0;
% structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
%                            5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
s.IRFt=2;

% activate forecast evaluation (1=yes, 0=no)
s.Feval=0;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
s.CFt=1;

%% Forecast 
s.Fstartdate='2017q2';  % start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
s.Fenddate='2020q1';    % end date for forecasts
s.Fendsmpl=0;           % start forecasts immediately after the final sample period (1=yes, 0=no) has to be set to 1 if start date for forecasts is not in-sample

s.Feval=1;              % activate forecast evaluation (1=yes, 0=no)
s.hstep=1;              % step ahead evaluation
s.window_size=0;        % window_size for iterative forecasting 0 if no iterative forecasting
s.evaluation_size=0.5;  % evaluation_size as percent of window_size                                      <                                                                                    -

%% Credibility bands
s.cband=0.68;    % confidence/credibility level for VAR coefficients
s.IRFband=0.68;  % confidence/credibility level for impusle response functions
s.Fband=0.68;    % confidence/credibility level for forecasts
s.FEVDband=0.68; % confidence/credibility level for forecast error variance decomposition
s.HDband=0.68;   % confidence/credibility level for historical decomposition
