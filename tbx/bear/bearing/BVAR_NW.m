clear
%% set options
excelFile = fullfile(bearroot(), 'replications','data_.xlsx') ;
%Choose VAR type
VARtype = 2;
% Choose frequency
frequency = 2;
% sample start date; must be a string consistent with the date formats of the toolbox
startdate = '1974q1';
% sample end date; must be a string consistent with the date formats of the toolbox
enddate = '2014q4';
% endogenous variables; must be a single string, with variable names separated by a space
varendo = 'DOM_GDP DOM_CPI STN';
% exogenous variables, if any; must be a single string, with variable names separated by a space
varexo = '';
% number of lags
lags = 4;
% inclusion of a constant (1=yes, 0=no)
const = 1;
% excel results file name
results_sub = 'results_bvar_nw';
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

% BVAR specific information: will be read only if VARtype=2

% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
% 61=Mean-adjusted
prior = 21;
% hyperparameter: autoregressive coefficient
ar = 1;
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
% hyperparameter: lambda6
lambda6 = 1;
% hyperparameter: lambda7
lambda7 = 0.1;
% Overall tightness on the long run prior
lambda8 = 1;
% (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
priorf = 100;
% total number of iterations for the Gibbs sampler
It = 2000;
% number of burn-in iterations for the Gibbs sampler
Bu = 1000;
% hyperparameter optimisation by grid search (1=yes, 0=no)
hogs = 0;
% block exogeneity (1=yes, 0=no)
bex = 0;
% sum-of-coefficients application (1=yes, 0=no)
scoeff = 0;
% dummy initial observation application (1=yes, 0=no)
iobs = 0;
% Long run prior option
lrp = 0;
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
Fstartdate = '2014q1';
% end date for forecasts
Fenddate = '2016q4';
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

for iteration=1:numt % beginning of forecasting loop
    if window_size>0
%         data_endo = data_endo_full(iteration:window_size+iteration,:);
        Fstartlocation1 = find(strcmp(names(1:end,1),startdateini))+iteration-1;
        startdate = char(names(Fstartlocation1,1));
        Fendlocation = find(strcmp(names(1:end,1),startdateini))+window_size+iteration-1;
        enddate = char(names(Fendlocation,1));
        if F>0
            Fstartdate = char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+1,1));
            Fenddate = char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+hstep,1));
        end
            [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4,favar]...
                = bear.gensample(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,ar,lambda4,PriorExcel,priorsexogenous,pref,favar,IRFt, n);

        % generate the strings and decimal vectors of dates
        [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation] =  ...
                    bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);
    end

    %% BLOCK 1: OLS ESTIMATES
    [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q] = bear.olsvar(data_endo,data_exo,const,lags);
    [arvar] = bear.arloop(data_endo,const,p,n);

    %% BLOCK 2: PRIOR EXTENSIONS, estimation
    % implement any dummy observation extensions that may have been selected
    [Ystar,ystar,Xstar,Tstar,Ydum,ydum,Xdum,Tdum] = ...
            bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,lambda6,lambda7,lambda8,scoeff,iobs,lrp,H);

    % set prior values
    [B0,beta0,phi0,S0,alpha0] = bear.nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo);
    % obtain posterior distribution parameters
    [Bbar,betabar,phibar,Sbar,alphabar,alphatilde] = bear.nwpost(B0,phi0,S0,alpha0,Xstar,Ystar,n,Tstar,k);
    [beta_gibbs,sigma_gibbs] = bear.nwgibbs(It,Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);
    [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median] = bear.nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband);

    [struct_irf_record,D_record,gamma_record,hd_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
            = bear.irfres_prior(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,HD,const,exo,strctident,pref,favar,IRFt,It,Bu,prior);


    %% BLOCK 3: MODEL EVALUATION
    [logml,log10ml,ml] = bear.nwmlik(Xstar,Xdum,Ydum,n,Tstar,Tdum,k,B0,phi0,S0,alpha0,Sbar,alphabar,scoeff,iobs);
    [dic] = bear.dic_test(Y,X,n,beta_gibbs,sigma_gibbs,It-Bu,favar);

    % display the VAR results
    
    bear.bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,dic,X,Y,n,m,p,k,q,T,prior,bex,hogs,lrp,H,ar,lambda1,lambda2,lambda3,lambda4,lambda5,lambda6,lambda7,lambda8,IRFt,const,beta_gibbs,endo,data_endo,exo,startdate,enddate,decimaldates1,stringdates1,pref,scoeff,iobs,PriorExcel,strctident,favar,theta_median,TVEH,indH);

    % compute and display the steady state results
    [ss_record] = bear.ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu,favar);
    [ss_estimates] = bear.ssestimates(ss_record,n,T,cband);
     % display steady state
    bear.ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref);
    
    %% BLOCK 4: IRF
    [strshocks_estimates] = bear.strsestimates_set_identified(ETA_record,n,T,IRFband,struct_irf_record,IRFperiods,strctident);
    bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
    [irf_estimates,D_estimates,gamma_estimates,favar] = bear.irfestimates_set_identified(struct_irf_record,n,IRFperiods,IRFband,D_record,strctident,favar);
    bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);

    %% BLOCK 5: FORECASTS
    [forecast_record] = bear.forecast(data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const,Fstartlocation,favar);
    % compute posterior estimates
    [forecast_estimates] = bear.festimates(forecast_record,n,Fperiods,Fband);
    % display the results for the forecasts
    bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
    [Forecasteval] =...
        bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
    
    %% BLOCK 6: FEVD
    % run the Gibbs sampler to compute posterior draws
    [fevd_estimates] = bear.fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
    
    %% BLOCK 7: historical decomposition
    % run the Gibbs sampler to compute posterior draws
    [hd_record,favar] = bear.hdecomp_inc_exo(beta_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar);
    % compute posterior estimates
    [hd_estimates,favar] = bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
    % display
    bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
    
    %% BLOCK 8: conditional forecast
    % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
    [cforecast_record,CFstrshocks_record] = bear.cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
    % compute posterior estimates
    [cforecast_estimates] = bear.festimates(cforecast_record,n,Fperiods,Fband);
    % display the results for the forecasts
    bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
    
    %% Block 9: saving results
    if pref.workspace==1
        if numt>1
            save(fullfile(pref.results_path, [ pref.results_sub Fstartdate '.mat'] )); % Save Workspace
        end
    end

    Fstartdate_rolling = [Fstartdate_rolling; Fstartdate];
end
if numt>1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rolling forecast evaluation
    % based on Francesca Loria
    % This Version: February 2018
    % Input:
    % 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
    %see later
    %gr_pf_windowSize = 19;
    %gr_pf_windowSize = round(evaluation_size*window_size);

    % 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
    %see later
    %rs_pf_windowSize = 25;
    %rs_pf_windowSize = round(evaluation_size*window_size);

    % 3. See Section 7. for Additional User Input required for Density Forecast Evaluation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    RMSE_rolling = [];
    for i = 1:numt
        Fstartdate=char(Fstartdate_rolling(i,:));
        output = char(strcat(fullfile(pref.results_path, [pref.results_sub Fstartdate '.mat'])));
        % load forecasts
        load(output,'forecast_estimates','forecast_record','varendo','names','frequency', 'Forecasteval')
        % load OLS AR forecast estimates as benchmark
        load(output,'OLS_forecast_estimates', 'OLS_Bhat', 'OLS_betahat', 'OLS_sigmahat', 'biclag')

        for j = 1:length(forecast_estimates)
            ols_forecasts(j,i)    = OLS_forecast_estimates{1,j}{1,1}(2,hstep); % assign median
            forecasts(j,i)        = forecast_estimates{j}(2,hstep); % assign median
            forecasts_dist(:,j,i) = sort(forecast_record{j,1}(:,1));     % assign entire distribution
        end
        sample=['f' Fstartdate];
        RMSE_rolling = [RMSE_rolling; Forecasteval.RMSE];
        Rolling.RMSE.(sample)=Forecasteval.RMSE;
        Rolling.MAE.(sample)=Forecasteval.MAE;
        Rolling.MAPE.(sample)=Forecasteval.MAPE;
        Rolling.Ustat.(sample)=Forecasteval.Ustat;
        Rolling.CRPS_estimates.(sample)=Forecasteval.CRPS_estimates;
        Rolling.S1_estimates.(sample)=Forecasteval.S1_estimates;
        Rolling.S2_estimates.(sample)=Forecasteval.S2_estimates;
    end

    %% Load Actual Data and Other Inputs
    actualdata = data(end-numt+1:end,:)';
    save('forecast_eval.mat','forecasts','actualdata');

    var_feval = endo;

    % Block size for the Inoue (2001) bootstrap procedure,
    % default is P^(1/3), where P is the size of the out-of-sample portion of
    % the available sample of size T+h
    P = length(forecasts);
    el = round(P^(1/3));

    % 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
    %gr_pf_windowSize = 19;
    gr_pf_windowSize = round(evaluation_size*P);

    % 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
    %rs_pf_windowSize = 25;
    %rs_pf_windowSize = round(evaluation_size*window_size);
    rs_pf_windowSize = round(evaluation_size*P);


    % 5. Number of bootstrap replications in the calculation of CV for the
    % Rossi-Sekhposyan test for multiple-step ahead forecast densities (h>1),
    % default is 300
    bootMC = 300;


    for ind_feval=1:length(endo) %index of selected variable
        ind_deval=ind_feval;

        %Grid
        for ii=1:size(forecasts_dist(:,ind_feval(1),:),3)
            for jj=1:size(forecasts_dist(:,ind_feval(1),:),1)-1
                diff(jj) = squeeze(forecasts_dist(jj+1,ind_feval(1),ii) - forecasts_dist(jj,ind_feval(1),ii));
            end
            mdiff(ii) = mean(diff);
        end
        tdiff = max(mdiff);

        gridDF = min(floor(min(forecasts_dist(:,ind_feval(1),:)))):tdiff:max(ceil(max(forecasts_dist(:,ind_feval(1),:))));

        startdate = char(Fstartdate_rolling(1,:));
        enddate   = char(Fstartdate_rolling(end,:));
        [pdate,stringdate] = bear.genpdate(names,0,frequency,startdate,enddate);

        bear.RS_PF(names, endo, ind_deval, actualdata, forecasts, ind_feval, rs_pf_windowSize, pdate); % Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
        bear.RS_DF(actualdata, gridDF, Bu, forecasts_dist, ind_feval, ind_deval, hstep, el, bootMC); % Rossi-Sekhposyan (2016) Tests for Correct Specification of Forecast Densities
        bear.GR_PF(forecasts, ind_feval, ols_forecasts, actualdata, pdate,gr_pf_windowSize, biclag, endo); % Giacomini-Rossi JAE(2010) Fluctuation Test


    end %loop ind_feval
end

% option to save matlab workspace
if pref.workspace==1
    save( fullfile(pref.results_path, [pref.results_sub '.mat']) );
end