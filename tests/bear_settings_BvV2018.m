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
VARtype=5;
% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
frequency=2;
% sample start date; must be a string consistent with the date formats of the toolbox
startdate='1970q2';
% sample end date; must be a string consistent with the date formats of the toolbox
enddate='2020q1';
% endogenous variables; must be a single string, with variable names separated by a space
varendo='YER HICSA STN'; %
varexo='';
% number of lags
lags=4;
% inclusion of a constant (1=yes, 0=no)
const=0;
% path to data; must be a single string
cd ..\
pref.datapath=pwd; % main BEAR folder, specify otherwise
cd .\files
% excel results file name
pref.results_sub='results_BvV2018';
% to output results in excel
pref.results=1;
% output charts
pref.plot=1;
% pref: useless by itself, just here to avoid code to crash
pref.pref=0;
% save matlab workspace (1=yes, 0=no)
pref.workspace=0;

% OLS VAR specific information: will be read only if VARtype=1
if VARtype==1
% FAVAR options, for OLS (VARtype=1) only
favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)
    if favar.FAVAR==1
    % transform information variables in excel sheet 'factor data' (following Stock & Watson: 1 Level, 2 First Difference, 3 Second Difference, 4 Log-Level, 5 Log-First-Difference, 6 Log-Second-Difference)
    favar.transformation=0; % (1=yes, 0=no) // 'factor data' must contain values for startdate -1 in the case we have First Difference (2,5) transformation types and startdate -2 in the case we have Second Difference (3,6) transformation types
		favar.transform_endo=''; %'2 6' transformation codes of varendo variables other than factors
	% demeans (information) data in excel sheets 'data' and 'factor data' 
    favar.demean=1; % (1=yes, 0=no)
    % specify the ordering of endogenpous factors and variables
    varendo='slow.factor1 slow.factor2 Fedfunds CPITRNSL fast.factor1 fast.factor2'; 
    
    % blocks/categories (1=yes, 0=no), specify in excel sheet
    favar.blocks=1;
        if favar.blocks==0 % basic favar model without blocks (basically one block)
            favar.numpc=4; % choose number of factors (principal components) to include
        elseif favar.blocks==1 % assign information variables to blocks
            favar.blocknames='slow fast'; % specify in excel sheet 'factor data'
            favar.blocknumpc='2 2'; %block-specific number of factors (principal components)
        end
      
    % specify information variables of interest (plot and excel output) (HD & IRFs)
    favar.plotX='INDPRO UNRATE USCONCONF';
    % (approximate) HD for information variables
    favar.HD.plot=0; % (1=yes, 0=no)
    if favar.HD.plot==1
        favar.HD.sumShockcontributions=0; % sum contributions over shocks (=1), or over variables (=0, standard), only for IRFt2,3\\this option makes no sense in IRFt4,6
        favar.HD.plotXblocks=1; % sum contributions of factors blockwise
            favar.HD.HDallsumblock=0; % include all components of HDall(=1) other than shock contributions, but display them sumed under blocks\shocks
    end
    % (approximate) IRFs for information variables 
    favar.IRF.plot=1; % (1=yes, 0=no)
    if favar.IRF.plot==1
        % choose shock(s) to plot
        favar.IRF.plotXshock='Fedfunds'; % Fedfunds 'USMP'
        favar.IRF.plotXblocks=0;
    end
    % (approximate) FEVDs for information variables
    favar.FEVD.plot=0; % (1=yes, 0=no)
	if favar.FEVD.plot==1
		% choose shock(s) to plot
        favar.FEVD.plotXshock=varendo;%'EA.factor1 EA.factor2 EA.factor3 EA.factor4 EA.factor5 EA.factor6';
    end
    end  
    
    
% BVAR specific information: will be read only if VARtype=2

elseif VARtype==2
% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
prior=31;
% hyperparameter: autoregressive coefficient
ar=0.8; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
% switch to Excel interface
PriorExcel=1; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
priorsexogenous=1; % set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
lambda1=0.01;
% hyperparameter: lambda2
lambda2=0.5;
% hyperparameter: lambda3
lambda3=1;
% hyperparameter: lambda4
lambda4=1;
% hyperparameter: lambda5
lambda5=0.001;
% hyperparameter: lambda6
lambda6=1;
% hyperparameter: lambda7
lambda7=0.1;
% Overall tightness on the long run prior
lambda8=1;
% total number of iterations for the Gibbs sampler
It=2000;
% number of burn-in iterations for the Gibbs sampler
Bu=1000;
% hyperparameter optimisation by grid search (1=yes, 0=no)
hogs=0;
% block exogeneity (1=yes, 0=no)
bex=0;
% sum-of-coefficients application (1=yes, 0=no)
scoeff=0;
% dummy initial observation application (1=yes, 0=no)
iobs=0;
% Long run prior option
lrp=0;
% create H matrix for the long run priors 
% now taken from excel loadH.m
% H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
% (61=Mean-adjusted BVAR) Scale up the variance of the prior of factor f
priorf=100;

elseif VARtype==3






% Stochastic volatility BVAR information: will be read only if VARtype=5

elseif VARtype==5
% choice of stochastic volatility model 
% 1=standard, 2=random scaling, 3=large BVAR 4=TVESLM Model
stvol=4;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
if pick==0
    pickf=5;
end 
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=5;
% block exogeneity (1=yes, 0=no)
bex=0;
% hyperparameter: autoregressive coefficient
ar=0;
% switch to Excel interface
PriorExcel=0; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
% total number of iterations for the Gibbs sampler
It=2000;
% number of burn-in iterations for the Gibbs sampler
Bu=1000;
%switch to Excel interface for exogenous variables
% hyperparameter: lambda1
lambda1=0.2;
% hyperparameter: lambda2
lambda2=0.7071;
% hyperparameter: lambda3
lambda3=1;
% hyperparameter: lambda4
lambda4=100;
% hyperparameter: lambda5
lambda5=0.001;
% hyperparameter: gama
gamma=1;
% % hyperparameter: alpha0
% alpha0=0.001;
% % hyperparameter: delta0
% delta0=0.001;
% % hyperparameter: gamma0
% gamma0=0;
% % hyperparameter: zeta0
% zeta0=10000;


% panel Bayesian VAR specific information: will be read only if VARtype=4
elseif VARtype==4
% choice of panel model 
% 1=OLS mean group estimator, 2=pooled estimator
% 3=random effect (Zellner and Hong), 4=random effect (hierarchical)
% 5=static factor approach, 6=dynamic factor approach
panel=2;
% units; must be single sstring, with names separated by a space
unitnames='US EA UK';
% total number of iterations for the Gibbs sampler
It=2000;
% number of burn-in iterations for the Gibbs sampler
Bu=1000;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;
% hyperparameter: autoregressive coefficient
ar=0.8;
% hyperparameter: lambda1
lambda1=0.1;
% hyperparameter: lambda2
lambda2=0.5;
% hyperparameter: lambda3
lambda3=1;
% hyperparameter: lambda4
lambda4=100;
% hyperparameter: s0
s0=0.001;
% hyperparameter: v0
v0=0.001;
% hyperparameter: alpha0
alpha0=1000;
% hyperparameter: delta0
delta0=1;
% hyperparameter: gama
gama=0.85;
% hyperparameter: a0
a0=1000;
% hyperparameter: b0
b0=1;
% hyperparameter: rho
rho=0.75;
% hyperparameter: psi
psi=0.1;




% Time-varying BVAR information: will be read only if VARtype=6
elseif VARtype==6
% choice of time-varying BVAR model 
% 1=time-varying coefficients, 2=general time-varying
tvbvar=2;
% total number of iterations for the Gibbs sampler
It=200;
% number of burn-in iterations for the Gibbs sampler
Bu=100;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;
% calculate IRFs for every sample period (1=yes, 0=no)
alltirf=1;
% hyperparameter: gama
gamma=0.85;
% hyperparameter: alpha0
alpha0=0.001;
% hyperparameter: delta0
delta0=0.001;
% just for the code to run (do not touch)
ar=0;
PriorExcel=0;
priorsexogenous=1;
lambda4=100;
end



% Model options

% activate impulse response functions (1=yes, 0=no)
IRF=1;
% number of periods for impulse response functions
IRFperiods=20;
% activate unconditional forecasts (1=yes, 0=no)
F=1;
% activate forecast error variance decomposition (1=yes, 0=no)
FEVD=1;
% activate historical decomposition (1=yes, 0=no)
HD=1; 
HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
% activate conditional forecasts (1=yes, 0=no)
CF=1;
% structural identification (1=none, 2=Cholesky, 3=triangular factorisation, 4=sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions,
%                            5=IV identification, 6=IV identification & sign, zero, magnitude, relative magnitude, FEVD, correlation restrictions)
IRFt=4;
    strctident.IRFt = IRFt; 
    %save in strctident
    %strctident.IRFt=IRFt;
    if IRFt==4 || IRFt==6 % if IRFt==4||IRFt==6 specify correlated Shock and Instrument
    strctident.CorrelShock='money'; % exact labelname of the shock defined in sign res values or sign res values (IV);;; 'noexist' if unspecified
    strctident.CorrelInstrument='gkmpshock_footnote'; % provide the IV variable in excel sheet IV;;; 'noexist' if unspecified
    strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
    end
    if IRFt==5 || IRFt==6 % if IRFt=5||IRFt==6; specify Instrument to identfy Shock
    strctident.Instrument='gkmpshock_footnote';%'jkmpshock_sumweighted'; %
    strctident.startdateIV='1992m2';
    strctident.enddateIV='1999m2';
    end
    if VARtype==1
        if IRFt==5 || IRFt==6
        strctident.bootstraptype=1; %1=wild bootstrap Mertens&Ravn(2013), 2=moving block bootstrap Jentsch&Lunsford(2018)
        end
    % strctident settings for Bayesian model only
    elseif VARtype==2
        % options for Bayesian IV model
        if IRFt==5 || IRFt==6
            strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
            strctident.Thin=10;
            strctident.prior_type_reduced_form=2; %1=flat (standard), 2=normal wishart , related to the IV routine
            strctident.Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
            strctident.prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)
        end
    end
    
% activate forecast evaluation (1=yes, 0=no)
Feval=1;
% type of conditional forecasts 
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
CFt=3;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
Fstartdate='2017q2';
% end date for forecasts
Fenddate='2020q1';
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
Fendsmpl=0;
% step ahead evaluation
hstep=1;
% window_size for iterative forecasting 0 if no iterative forecasting
window_size=0; 
% evaluation_size as percent of window_size                                      <                                                                                    -
evaluation_size=0.5;                          
% confidence/credibility level for VAR coefficients
cband=0.95;
% confidence/credibility level for impusle response functions
IRFband=0.68;
% confidence/credibility level for forecasts
Fband=0.68;
% confidence/credibility level for forecast error variance decomposition
FEVDband=0.95;
% confidence/credibility level for historical decomposition
HDband=0.68;