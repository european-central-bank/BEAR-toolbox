function s = bear_settings_MF(excelPath)

if nargin < 1
    s = BEARsettings(7);
else
    s = BEARsettings(7, 'ExcelFile', excelPath);
end

%% general data and model information
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=3;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='2000m2';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2021m2';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='ipi	ZEW	DAX	ifoclimate	ifoexpectations	Retail Manufacturingsales	Autprod	Worldtrade	WorldIP	ygdp'; % Germany
% endogenous variables; must be a single string, with variable names separated by a space
s.varexo='';
% number of lags
s.lags=6;
% inclusion of a constant (1=yes, 0=no)
s.const=1;
% excel results file name
s.results_sub='results_MF';
s.results_path = fullfile(pwd, 'results');
% to output results in excel
s.results=1;
% output charts
s.plot=1;
% save matlab workspace (1=yes, 0=no)
s.workspace=0;

%% Hyperparameters
% hyperparameter: autoregressive coefficient
s.ar=0.9;
% hyperparameter: lambda1
s.lambda1=1.e-01;
% hyperparameter: lambda2
s.lambda2=3.4;
% hyperparameter: lambda3
s.lambda3=1;
% hyperparameter: lambda4
s.lambda4=3.4;
% hyperparameter: lambda5
s.lambda5=1.4763158e+01;
% total number of iterations for the Gibbs sampler
s.It=5000;
% number of burn-in iterations for the Gibbs sampler
s.Bu=2000;
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

%% Model options
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
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
s.Fstartdate='2020m2';
% end date for forecasts
s.Fenddate='2021m12';
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
s.Fendsmpl=1;
% step ahead evaluation
s.hstep=1;
% window_size for iterative forecasting 0 if no iterative forecasting
s.window_size=0; 
% evaluation_size as percent of window_size                                      <                                                                                    -
s.evaluation_size=0.5;                          
% confidence/credibility level for VAR coefficients
s.cband=0.68;
% confidence/credibility level for impusle response functions
s.IRFband=0.68;
% confidence/credibility level for forecasts
s.Fband=0.68;
% confidence/credibility level for forecast error variance decomposition
s.FEVDband=0.95;
% confidence/credibility level for historical decomposition
s.HDband=0.68;