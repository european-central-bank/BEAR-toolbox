function s = bear_settings_BvV2018_test(excelPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    BAYESIAN ESTIMATION, ANALYSIS AND REGRESSION (BEAR) TOOLBOX           %
%                                                                          %
%    This statistical package has been developed by the external           %
%    developments division of the European Central Bank.                   %
%                                                                          %
%    Authors:                                                              %
%    Alistair Dieppe (alistair.dieppe@ecb.europa.eu)                               %
%    Björn van Roye  (Bjorn.van_Roye@ecb.europa.eu)                        %
%                                                                          %
%    Version 5.0                                                           %
%                                                                          %
%    The authors are grateful to the following people for valuable input   %
%    and advice which contributed to improve the quality of the toolbox:   %
%    Paolo Bonomolo, Mirco Balatti, Marta Banbura, Niccolo Battistini,     %
%	 Gabriel Bobeica, Martin Bruns, Fabio Canova, Matteo Ciccarelli,       %
%    Marek Jarocinski, Michele Lenza, Francesca Loria, Mirela Miescu,      %
%    Gary Koop, Chiara Osbat, Giorgio Primiceri, Martino Ricci,            %
%    Michal Rubaszek, Barbara Rossi, Ben Schumann, Marius Schulte,         %
%    Peter Welz and Hugo Vega de la Cruz. 						           %
%                                                                          %
%    These programmes are the responsibilities of the authors and not of   %
%    the ECB and all errors and ommissions remain those of the authors.    %
%                                                                          %
%    Using the BEAR toolbox implies acceptance of the End User Licence     %
%    Agreement and appropriate acknowledgement should be made.             %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% general data and model information

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
s = BEARsettings(5, 'ExcelPath', excelPath);
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
s.frequency=2;
% sample start date; must be a string consistent with the date formats of the toolbox
s.startdate='1970q2';
% sample end date; must be a string consistent with the date formats of the toolbox
s.enddate='2020q1';
% endogenous variables; must be a single string, with variable names separated by a space
s.varendo='YER HICSA STN'; %
s.varexo='';
% number of lags
s.lags=4;
% inclusion of a constant (1=yes, 0=no)
s.const=0;
% path to data
s.pref.datapath=fileparts(mfilename('fullpath')); % next to settings
% excel results file name
s.pref.results_sub='results_test_data_BvV2018_temp';
s.pref.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
% to output results in excel
s.pref.results=0;
% output charts
s.pref.plot=0;
% pref: useless by itself, just here to avoid code to crash
s.pref.pref=0;
% save matlab workspace (1=yes, 0=no)
s.pref.workspace=1;

% choice of stochastic volatility model
% 1=standard, 2=random scaling, 3=large BVAR 4=TVESLM Model
s.stvol=4;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
s.pick=0;

% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
s.pickf=5;
% block exogeneity (1=yes, 0=no)
s.bex=0;
% hyperparameter: autoregressive coefficient
s.ar=0;
% switch to Excel interface
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
% total number of iterations for the Gibbs sampler
s.It=2000;
% number of burn-in iterations for the Gibbs sampler
s.Bu=1000;
%switch to Excel interface for exogenous variables
% hyperparameter: lambda1
s.lambda1=0.2;
% hyperparameter: lambda2
s.lambda2=0.7071;
% hyperparameter: lambda3
s.lambda3=1;
% hyperparameter: lambda4
s.lambda4=100;
% hyperparameter: lambda5
s.lambda5=0.001;
% hyperparameter: gama
s.gamma=1;

% Model options

% activate impulse response functions (1=yes, 0=no)
s.IRF=1;
% number of periods for impulse response functions
s.IRFperiods=20;
% activate unconditional forecasts (1=yes, 0=no)
s.F=1;
% activate forecast error variance decomposition (1=yes, 0=no)
s.FEVD=1;
% activate historical decomposition (1=yes, 0=no)
s.HD=1;
s.HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
% activate conditional forecasts (1=yes, 0=no)
s.CF=1;
% structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
%                            5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
s.IRFt=4;
% s.strctident.IRFt = IRFt;
%save in strctident
%strctident.IRFt=IRFt;

s.strctident.CorrelShock='money'; % exact labelname of the shock defined in sign res values or sign res values (IV);;; 'noexist' if unspecified
s.strctident.CorrelInstrument='gkmpshock_footnote'; % provide the IV variable in excel sheet IV;;; 'noexist' if unspecified
s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)

% activate forecast evaluation (1=yes, 0=no)
s.Feval=1;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
s.CFt=3;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
s.Fstartdate='2017q2';
% end date for forecasts
s.Fenddate='2020q1';
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
s.FEVDband=0.95;
% confidence/credibility level for historical decomposition
s.HDband=0.68;