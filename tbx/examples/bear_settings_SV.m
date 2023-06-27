function s = bear_settings_SV(excelPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX version 5.1 %
%                                                                         %
% Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                         %
% Björn van Roye  (bvanroye@bloomberg.net)                                %
%                                                                         %
% Using the BEAR toolbox implies acceptance of the End User Licence       %
% Agreement and appropriate acknowledgement should be made.               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% STOCHASTIC VOLATILITY EXAMPLE

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying, 7=Mixed Frequency)
if nargin < 1
    s = BEARsettings(5);
else
    s = BEARsettings(5, 'ExcelFile', excelPath);
end

%% General data and model information
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=2;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='1971q1';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2020q1';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='YER HICSA STN';
% exogenous variables; must be a single string, with variable names separated by a space
s.varexo='';
% number of lags
s.lags=4;
% inclusion of a constant (1=yes, 0=no)
s.const=1;
% excel results file name
s.results_sub='results_SV';
s.results_path = fullfile(pwd,'results');
% to output results in excel
s.results=1;
% output charts
s.plot=1;
% save matlab workspace (1=yes, 0=no)
s.workspace=1;

%% Choice of stochastic volatility model 
% 1=standard, 
s.stvol="Standard";

%% Parameters
s.ar=0.8;         % hyperparameter: autoregressive coefficient
s.lambda1=0.1;    % hyperparameter: lambda1
s.lambda2=0.5;    % hyperparameter: lambda2
s.lambda3=1;      % hyperparameter: lambda3
s.lambda4=100;    % hyperparameter: lambda4
s.lambda5=0.001;  % hyperparameter: lambda5

s.PriorExcel=0;   % set to 1 if you want individual priors, 0 for default
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default

s.It=2000;   % total number of iterations for the Gibbs sampler
s.Bu=1000;   % number of burn-in iterations for the Gibbs sampler

s.bex=0; % block exogeneity (1=yes, 0=no)

%% Model options
s.IRF=1;          % activate impulse response functions (1=yes, 0=no)
s.IRFperiods=20;  % number of periods for impulse response functions
s.F=1;            % activate unconditional forecasts (1=yes, 0=no)
s.FEVD=0;         % activate forecast error variance decomposition (1=yes, 0=no)
s.HD=1;           % activate historical decomposition (1=yes, 0=no)
s.HDall=0;        % if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
s.CF=0;           % activate conditional forecasts (1=yes, 0=no)
s.CFt=1;          % 1=standard (all shocks), 2=standard (shock-specific), 3=tilting (median), 4=tilting (interval)

% structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
% 5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
s.IRFt=4;

% IV
%s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
%s.strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
%s.strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"

%% Forecast 
s.Fstartdate='2019q1';  % start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
s.Fenddate='2021q4';  % end date for forecasts
s.Fendsmpl=0;   % start forecasts immediately after the final sample period (1=yes, 0=no) has to be set to 1 if start date for forecasts is not in-sample

s.Feval=1;      % activate forecast evaluation (1=yes, 0=no)
s.hstep=1;      % step ahead evaluation
s.window_size=0;       % window_size for iterative forecasting 0 if no iterative forecasting
s.evaluation_size=0.5; % evaluation_size as percent of window_size                                      <                                                                                    -

%% Credibility bands
s.cband=0.68;    % confidence/credibility level for VAR coefficients
s.IRFband=0.68;  % confidence/credibility level for impusle response functions
s.Fband=0.68;    % confidence/credibility level for forecasts
s.FEVDband=0.68; % confidence/credibility level for forecast error variance decomposition
s.HDband=0.68;   % confidence/credibility level for historical decomposition
