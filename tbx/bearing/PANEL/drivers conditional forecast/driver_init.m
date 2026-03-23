addpath(genpath('../../../'))

excelFile = fullfile(bearroot(),'default_bear_data_with_crosscountry.xlsx') ;

%% Preferences options
%Choose VAR type
VARtype = 4;
% Choose frequency
frequency = 2;
% sample start date; must be a string consistent with the date formats of the toolbox
startdate = '1971q1';
% sample end date; must be a string consistent with the date formats of the toolbox
enddate = '2014q4';
% endogenous variables; must be a single string, with variable names separated by a space
varendo = 'YER HICSA STN';
% exogenous variables, if any; must be a single string, with variable names separated by a space
varexo = 'Oil';
% number of lags
lags = 4;13;
% inclusion of a constant (1=yes, 0=no)
const = 1;0;
% excel results file name
results_sub = 'results_Panel';
results_path = fullfile(fileparts(mfilename('fullpath')),'results');
% to output results in excel
results = 1;
% output charts
pplot = 1;
% save matlab workspace (1=yes, 0=no (default))
workspace = 0;

%% Specifications options
unitnames = 'US EA UK';
% total number of iterations for the Gibbs sampler
It=400;2000;
% number of burn-in iterations for the Gibbs sampler
Bu=200;1000;   
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick = false;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;
% autoregressive coefficient (panel 1,2,3,4,5,6)
ar = 0.8;
% hyperparameter: lambda1 (panel 3)
lambda1 = 0.1;
% hyperparameter: lambda2 (panel 4)
lambda2 = 0.5;
% hyperparameter: lambda3 (panel 4)
lambda3 = 1;
% hyperparameter: lambda4 (panel 1,3,4,5,6)
lambda4 = 100;
% hyperparameter: s0 (panel 4)
s0 = 0.001;
% hyperparameter: v0 (panel 4)
v0 = 0.001;
% AR coefficient on residual variance: gamma (panel 6)
gamma = 0.85;
% IG shape on residual variance: alpha0 (panel 5,6)
alpha0 = 1000;
% % IG scale on residual variance: delta0 (panel 5,6)
delta0 = 1;
% % hyperparameter: a0  (panel 6)
a0 = 1000;
% % hyperparameter: b0 (panel 6)
b0 = 1;
% % hyperparameter: rho (panel 6)
rho = 0.75;
% % hyperparameter: psi (panel 6)
psi = 0.1;

%% Application options
% activate impulse response functions (1=yes, 0=no)
IRF = 1;
% activate unconditional forecasts (1=yes, 0=no)
F = 1;
% activate forecast error variance decomposition (1=yes, 0=no)
FEVD = 0;1;
% activate historical decomposition (1=yes, 0=no)
HD = 0;1;
Dall = 0;
% activate conditional forecasts (1=yes, 0=no)
CF = 1;
% panel type:
% 1 - mean OLS
% 2 - Bayesian
% 3 - Random eff.
% 4 - Random eff. hierarchy
% 5 - Factor static
% 6 - Factor dynamic 

% IRFt structural identification (1=none, 2=Choleski, 3=triangular factorisation, 4=sign restrictions)
% allowed IRFt combinations
% panel 1 (1-3)
% panel 2 (1-4)
% panel 3 (1-4)
% panel 4 (1-4)
% panel 5 (1-3)
% panel 6 (1-3)
IRFt = 2;
% type of conditional forecasts
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
CFt = 2;
% number of periods for impulse response functions
IRFperiods = 20;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
Fstartdate = '2014q2';%'2014q2';
% end date for forecasts
Fenddate = '2015q4';%'2015q4';
% activate forecast evaluation (1=yes, 0=no)
Feval=0;1;
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
Fendsmpl = 0;
% step ahead evaluation
hstep = 1;
% window_size for iterative forecasting 0 if no iterative forecasting
window_size = 0;
% evaluation_size as percent of window_size    
evaluation_size = 0.5;
% confidence/credibility level for VAR coefficients
cband = 0.68;
% confidence/credibility level for impusle response functions
IRFband = 0.68;
% confidence/credibility level for forecasts
Fband = 0.9;0.68;
% confidence/credibility level for forecast error variance decomposition
FEVDband = 0.68;
% confidence/credibility level for historical decomposition
HDband = 0.68;

% signreslabels empty element: required to have the argument for IRF plots, even if sign restriction is not selected
signreslabels=[];

strctident.strctident=0;
% turn off the correl res routines
strctident.CorrelInstrument="";
%exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
strctident.CorrelShock="";

pref = struct('excelFile', excelFile, ...
        'results_path', results_path, ...
        'results_sub', results_sub, ...
        'results', results, ...
        'plot', pplot, ...
        'workspace', workspace);


% as a preliminary task, fix all the strings that may require it
startdate=bear.utils.fixstring(startdate);
enddate=bear.utils.fixstring(enddate);
varendo=bear.utils.fixstring(varendo);
varexo=bear.utils.fixstring(varexo);
unitnames=bear.utils.fixstring(unitnames);

% look for the spaces and identify their locations
findspace=isspace(varendo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(varendo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo=nspace+1;
% now finally identify the endogenous
endo=cell(numendo,1);
for ii=1:numendo
    endo{ii,1}=varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

% proceed similarly for exogenous series; note however that it may be empty
% so check first whether there are exogenous variables altogether
if isempty(varexo==1)
    exo={};
    % if not empty, repeat what has been done with the exogenous
else
    findspace=isspace(varexo);
    locspace=find(findspace);
    delimiters=[0 locspace numel(varexo)+1];
    nspace=sum(findspace(:)==1);
    numexo=nspace+1;
    exo=cell(numexo,1);
    for ii=1:numexo
        exo{ii,1}=varexo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
    end
end

% look for the spaces and identify their locations
findspace=isspace(unitnames);
locspace=find(findspace);
% use this to set the delimiters: each unit string is located between two delimiters
delimiters=[0 locspace numel(unitnames)+1];
% count the number of units
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two unit names, so there is one unit more than the number of spaces
numunits=nspace+1;
% now finally identify the units
Units=cell(numunits,1);
for ii=1:numunits
    Units{ii,1}=unitnames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

% FAVAR options
favar.FAVAR     = 0; % augment VAR model with factors (1=yes, 0=no)
favar.HDplot    = false;
favar.IRFplot   = false;
favar.FEVDplot  = false;

%% Data loading
% initiation of Excel result file
bear.initexcel(pref);

% count the number of endogenous variables
n=size(endo,1);

[names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4]...
              =bear.gensamplepan(startdate,enddate,Units,panel,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,ar,0,0, n);



% load sign restrictions table, relative magnitude restrictions table, FEVD restrictions table
if IRFt==4
    [signrestable,signresperiods,signreslabels,strctident,favar]=bear.loadsignres(n,endo,pref,favar,IRFt,strctident);

    [relmagnrestable,relmagnresperiods,signreslabels,strctident,favar]=bear.loadrelmagnres(n,endo,pref,favar,IRFt,strctident);

    [FEVDrestable,FEVDresperiods,signreslabels,strctident,favar]=bear.loadFEVDres(n,endo,pref,favar,IRFt,strctident);

    [strctident,signreslabels]=bear.loadcorrelres(strctident,endo,names,startdate,enddate,lags,n,IRFt,favar,pref);
end

%---------------------|
% Table loading phase |
%------------------- -|            
if CF==1
    [cfconds,cfshocks,cfblocks]=bear.loadcfpan(endo,Units,panel,CFt,Fstartdate,Fenddate,Fperiods,pref);
end

%--------------------|
% Excel record phase |
%--------------------|

% record the estimation information
% [estimationinfo] = bear.data.excelrecord1fcn(endo, exo, Units, opts);

%-----------------------|
% date generation phase |
%-----------------------|

% generate the strings and decimal vectors of dates
[decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);

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
