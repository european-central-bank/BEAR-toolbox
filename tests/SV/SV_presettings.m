clear all
%% set options
%addpath(genpath('C:\Users\balint.parragi\BEAR-toolbox-6\tbx'))
addpath(genpath('../../'))

excelFile = fullfile(bearroot(),'default_bear_data.xlsx') ;
%Choose VAR type
VARtype = 5;
% Choose frequency
frequency = 2;
% sample start date; must be a string consistent with the date formats of the toolbox
startdate = '1971q1';
% sample end date; must be a string consistent with the date formats of the toolbox
enddate = '2020q1';
% endogenous variables; must be a single string, with variable names separated by a space
varendo = 'YER HICSA STN';
% exogenous variables, if any; must be a single string, with variable names separated by a space
varexo = '';
% number of lags
lags = 4;
% inclusion of a constant (1=yes, 0=no)
const = 1;
% excel results file name
results_sub = 'results_SV';
results_path = fullfile(fileparts(mfilename('fullpath')),'results');
% to output results in excel
results = 1;
% output charts
plot = 1;
% save matlab workspace (1=yes, 0=no (default))
workspace = 0;

% FAVAR options
favar.FAVAR     = 0; % augment VAR model with factors (1=yes, 0=no)
favar.HDplot    = false;
favar.IRFplot   = false;
favar.FEVDplot  = false;

% signreslabels empty element: required to have the argument for IRF plots, even if sign restriction is not selected
signreslabels=[];
% Units empty element: required to record estimation information on Excel even if the selected model is not a panel VAR
Units=[];
% blockexo empty element: required to have the code run properly for the BVAR model if block exogeneity is not selected
blockexo=[];
% forecast and IRFs empty elements: required for the display of panel results if forecast/IRFs are disactivated
forecast_record=[];
forecast_estimates=[];
gamma_estimates=[];
D_estimates=[];
% gamma empty elements: required for the display of stochastic volatility results if selected model is not random inertia
gamma_median=[];

% BVAR specific information: will be read only if VARtype=5

% hyperparameter: autoregressive coefficient
ar = 0.8;
% switch to Excel interface
PriorExcel = 0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
priorsexogenous = 0; % set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
lambda1 = 0.1;
% hyperparameter: lambda2
lambda2 = 0.5;
% hyperparameter: lambda3
lambda3 = 1;
% hyperparameter: lambda4
lambda4 = 100;
% hyperparameter: lambda5
lambda5 = 0.001;
% AR coefficient on residual variance: gamma
gamma = 1;
% IG shape on residual variance: alpha0
alpha0 = 0.001;
% IG scale on residual variance: delta0
delta0 = 0.001;
% Prior mean of inertia parameter: gamma0
gamma0 = 0;
% Prior variance of inertia parameter: zeta0
zeta0 = 10000;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick = false;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=5;

% total number of iterations for the Gibbs sampler
It=2000;
% number of burn-in iterations for the Gibbs sampler
Bu=1000;   
% block exogeneity (1=yes, 0=no)
bex=1;

%% Model options
% activate impulse response functions (1=yes, 0=no)
IRF = 1;
% activate unconditional forecasts (1=yes, 0=no)
F = 1;
% activate forecast error variance decomposition (1=yes, 0=no)
FEVD = 1;
% activate historical decomposition (1=yes, 0=no)
HD = 0;
HDall = 0;
% activate conditional forecasts (1=yes, 0=no)
CF = 1;
% structural identification (1=none, 2=Choleski, 3=triangular factorisation, 4=sign restrictions)
IRFt = 4;
% IRFt options
% strctident settings for OLS model
strctident.MM = 0; % option for Median model (0=no (standard), 1=yes)
% Correlation restriction options:
strctident.CorrelShock = ''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
strctident.CorrelInstrument = ''; % provide the IV variable in excel sheet "IV"

% activate forecast evaluation (1=yes, 0=no)
Feval = 1;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
CFt = 1;
% number of periods for impulse response functions
IRFperiods = 20;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
Fstartdate = '2019q1';
% end date for forecasts
Fenddate = '2021q4';
% activate forecast evaluation (1=yes, 0=no)
Feval=1;      
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
Fendsmpl = 0;
% step ahead evaluation
hstep = 1;
% window_size for iterative forecasting 0 if no iterative forecasting
window_size = 0;
% evaluation_size as percent of window_size                                      <                                                                                    -
evaluation_size = 0.5;
% confidence/credibility level for VAR coefficients
cband = 0.95;
% confidence/credibility level for impusle response functions
IRFband = 0.95;
% confidence/credibility level for forecasts
Fband = 0.95;
% confidence/credibility level for forecast error variance decomposition
FEVDband = 0.95;
% confidence/credibility level for historical decomposition
HDband = 0.95;

pref = struct('excelFile', excelFile, ...
    'results_path', results_path, ...
    'results_sub', results_sub, ...
    'results', results, ...
    'plot', plot, ...
    'workspace', workspace);
%% first create initial elements to avoid later crash of the code
H = [];
theta_median = NaN; 
TVEH = NaN; 
indH = NaN;
%% Dates
startdate = bear.utils.fixstring(startdate);
enddate = bear.utils.fixstring(enddate);
varendo = bear.utils.fixstring(varendo);
varexo = bear.utils.fixstring(varexo);
Fstartdate = bear.utils.fixstring(Fstartdate);
Fenddate = bear.utils.fixstring(Fenddate);

%% Location of endo data
findspace = isspace(varendo);
locspace = find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters = [0 locspace numel(varendo) + 1];
% count the number of endogenous variables
% first count the number of spaces
nspace = sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo = nspace+1;
% now finally identify the endogenous
endo = cell(numendo,1);
for ii = 1:numendo
    endo{ii,1} = varendo(delimiters(1,ii) + 1:delimiters(1,ii + 1) - 1);
end

exo = {};
%% Data loading
% initiation of Excel result file
bear.initexcel(pref);

% count the number of endogenous variables
n = size(endo,1);
[names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,...
    Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4,favar] = ...
           bear.gensample(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,...
                ar,lambda4,PriorExcel,priorsexogenous,pref,favar,IRFt, n);

[blockexo]=bear.loadbex(endo,pref);
%% Load sign restrictions
[signrestable,signresperiods,signreslabels,strctident,favar] = bear.loadsignres(n,endo,pref,favar,IRFt,strctident);

[relmagnrestable,relmagnresperiods,signreslabels,strctident,favar] = bear.loadrelmagnres(n,endo,pref,favar,IRFt,strctident);

[FEVDrestable,FEVDresperiods,signreslabels,strctident,favar] = bear.loadFEVDres(n,endo,pref,favar,IRFt,strctident);

[strctident,signreslabels] = bear.loadcorrelres(strctident,endo,names,startdate,enddate,lags,n,IRFt,favar,pref);

%% Load Conditional forecast tabels
[cfconds,cfshocks,cfblocks,cfintervals] = bear.loadcf(endo,CFt,Fstartdate,Fenddate,Fperiods,pref);

%% Excel record phase |

% record the estimation information
% [estimationinfo] = bear.data.excelrecord1fcn(endo, exo, Units, opts);

% generate the strings and decimal vectors of dates
[decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation] = ...
            bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);

%% Rolling forecasting loop

stringdatesforecast = stringdates2;
startdateini = startdate;
data_endo_full = data_endo;

numt = 1;% initialisation
Fstartdate_rolling = {};%to keep track of iterations
if window_size>length(stringdates1)
    msgbox('Forecasting window size greater than sample size');
    error('Forecasting window size greater than sample size');
elseif window_size>0
    numt = length(stringdates1)-window_size+lags; % number of different dateroll dates
end
