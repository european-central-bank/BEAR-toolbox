%% BEAR 5.0 
%  Using the BEAR toolbox implies acceptance of the End User Licence  %
%  Agreement and appropriate acknowledgement should be made.          %                                                        %

%% Settings following new interface
%%

% general data and model information

load appsettings

% VAR model selected (1=OLS VAR, 2=BVAR, 3=mean-adjusted BVAR, 4=panel Bayesian VAR, 5=Stochastic volatility BVAR, 6=Time varying)
if appsettings.OLS.Value==1 VARtype=1;
elseif appsettings.VARtype.Value(1:2)=='Ba' VARtype=2;
elseif appsettings.VARtype.Value(1:2)=='Pa' VARtype=4;
elseif appsettings.VARtype.Value(1:2)=='Ti' VARtype=5;
elseif appsettings.MFVAR.Value==1 VARtype=7;
%elseif appsettings.VARtype.Value(1:2)=='Ti' VARtype=6;
end

% data frequency (1=yearly, 2= quarterly, 3=monthly, 4=weekly, 5=daily, 6=undated)
if appsettings.frequency.Value(1:2)=='Ye' frequency=1;
elseif appsettings.frequency.Value(1:2)=='Qu' frequency=2;
elseif appsettings.frequency.Value(1:2)=='Mo' frequency=3;
elseif appsettings.frequency.Value(1:2)=='We' frequency=4;
elseif appsettings.frequency.Value(1:2)=='Da' frequency=5;
elseif appsettings.frequency.Value(1:2)=='Un' frequency=6;
end
% sample start date; must be a string consistent with the date formats of the toolbox
startdate=appsettings.startdate.Value;
% sample end date; must be a string consistent with the date formats of the toolbox
enddate=appsettings.enddate.Value;
% endogenous variables; must be a single string, with variable names separated by a space
varendo=appsettings.varendo.Value{1:end};
% exogenous variables, if any; must be a single string, with variable names separated by a space
varexo=appsettings.varexo.Value{1:end};
% number of lags
lags=appsettings.lags.Value;
% inclusion of a constant (1=yes, 0=no)
if appsettings.constant.Value(1:2)=='Of'
const=0; else const=1; end;
% path to data; must be a single string
pref.datapath=appsettings.datapath.Value{1:end};
% excel results file name
pref.results_sub=appsettings.results_sub.Value;
% to output results in excel
pref.results=appsettings.results.Value;
% output charts
pref.plot=appsettings.plot.Value;
% pref: useless by itself, just here to avoid code to crash
pref.pref=0;
% save matlab workspace (1=yes, 0=no (default))
pref.workspace=0;

% FAVAR options

favar.FAVAR=appsettings.FAVAR.Value;
if favar.FAVAR==1
    % transform information variables in excel sheet 'factor data' (following Stock & Watson: 1 Level, 2 First Difference, 3 Second Difference, 4 Log-Level, 5 Log-First-Difference, 6 Log-Second-Difference)
    % checking the option by comparing the strings like that is not elegant and inefficent
    favar.transformation=appsettings.transformation.Value; % (1=yes, 0=no) // 'factor data' must contain values for startdate -1 in the case we have First Difference (2,5) transformation types and startdate -2 in the case we have Second Difference (3,6) transformation types
    favar.transform_endo=appsettings.transform_endo.Value; %transformation codes of varendo variables other than factors (ordering follows 'data' sheet!)
    
    % number of factors to include
    favar.numpc=appsettings.numpc.Value;
    
    % blocks/categories (1=yes, 0=no), specify in excel sheet
    favar.blocks=appsettings.blocks.Value;
    if favar.blocks==1 % assign information variables to blocks
        favar.blocknames=appsettings.blocknames.Value; % specify in excel sheet 'factor data'
        favar.blocknumpc=appsettings.blocknumpc.Value; %block-specific number of factors (principal components)
    end
    
    
    % slow fast scheme for recursive identification (IRFt 2, 3) as in BBE (2005)
    favar.slowfast=appsettings.slowfast.Value; % assign variables in the excel sheet 'factor data' in the 'block' row to "slow" or "fast"

    % VARtype specific FAVAR options
    if VARtype==2 % supported priors: 1x, 2x, 3x, 41
        favar.onestep=appsettings.onestep.Value; % Bayesian estimation of factors and the model in an one-step estimation (1=yes, 0=no (two-step))
        % thining of Gibbs draws
        favar.thin=1; % (=1 default, no thinning)
        % priors on factor equation
        % Loadings L~N(0,L0*eye)
        favar.L0=1; %BBE set-up
        % Covariance Sigma~IG(a,b)
        favar.a0=3; %BBE set-up
        favar.b0=0.001; %BBE set-up
    end
    
    % specify information variables of interest (IRF, FEVD, HD)
    favar.plotX=appsettings.plotX.Value;
    
    % choose shock(s) to plot
    favar.plotXshock=appsettings.plotXshock.Value;
    
    % re-tranform transformed variables
    favar.levels=1; % =0 no re-transformation (default), =1 cumsum, =2 exp cumsum
    favar.retransres=1; % re-transform the candidate IRFs in IRFt4, before checking the restrictions
    
    % (approximate) IRFs for information variables
    favar.IRF.plot=appsettings.favarIRFplot.Value;
    
    %if favar.IRF.plot==1
        % choose shock(s) to plot
    %    favar.IRF.plotXshock='Fedfunds'; % Fedfunds 'USMP'
    %    favar.IRF.plotXblocks=0;
    %end

    % (approximate) FEVDs for information variables
    favar.FEVD.plot=appsettings.favarFEVDplot.Value;
    
    % (approximate) HD for information variables
    favar.HD.plot=appsettings.favarHDplot.Value;
    
    if favar.HD.plot==1
        favar.HD.sumShockcontributions=0; % sum contributions over shocks (=1), or over variables (=0, standard), only for IRFt2,3\\this option makes no sense in IRFt4,6
        if favar.blocks==1 % plotting options
            favar.HD.plotXblocks=1; % sum contributions of factors blockwise
            favar.HD.HDallsumblock=0; % include all components of HDall(=1) other than shock contributions, but display them sumed under blocks\shocks (=0, default)
        end
    end
end

% OLS VAR specific information: will be read only if VARtype=1
if VARtype==1
Instrument='';
ar=0;
lambda4=0;
PriorExcel=0;
priorsexogenous=0;
% BVAR specific information: will be read only if VARtype=2

elseif VARtype==2
% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
if appsettings.BayesianVARpriors.Value(1:2)=='Mi' prior=11;
elseif appsettings.BayesianVARpriors.Value(1:7)=='NormalW' prior=21;
elseif appsettings.BayesianVARpriors.Value(1:2)=='In' prior=31;
elseif appsettings.BayesianVARpriors.Value(1:7)=='NormalD' prior=41;
elseif appsettings.BayesianVARpriors.Value(1:2)=='Du' prior=51;
elseif appsettings.BayesianVARpriors.Value(1:2)=='De' prior=61;
end

% hyperparameter: autoregressive coefficient
ar=appsettings.ar.Value; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
% switch to Excel interface
PriorExcel=appsettings.PriorExcel.Value; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
priorsexogenous=0;
if appsettings.priorexogenous.Value(1:2)=='Ex' priorsexogenous=1; end% set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
lambda1=appsettings.lambda1.Value;
% hyperparameter: lambda2
lambda2=appsettings.lambda2.Value;
% hyperparameter: lambda3
lambda3=appsettings.lambda3.Value;
% hyperparameter: lambda4
lambda4=0.1;
if priorsexogenous==0 lambda4=100; end
    
%appsettings.lambda4.Value;
% hyperparameter: lambda5
lambda5=appsettings.lambda5.Value;
% hyperparameter: lambda6
lambda6=appsettings.lambda6.Value;
% hyperparameter: lambda7
lambda7=appsettings.lambda7.Value;
% Overall tightness on the long run prior
lambda8=appsettings.lambda8.Value;
% total number of iterations for the Gibbs sampler
It=appsettings.It.Value;
% number of burn-in iterations for the Gibbs sampler
Bu=appsettings.Bu.Value;
% hyperparameter optimisation by grid search (1=yes, 0=no)
hogs=0;
if appsettings.hogs.Value(1:2)=='Ye' hogs=1; end;
% block exogeneity (1=yes, 0=no)
bex=0;
if appsettings.bex.Value(1:2)=='Ye' bex-1; end
% sum-of-coefficients application (1=yes, 0=no)
scoeff=appsettings.scoeff.Value;
% dummy initial observation application (1=yes, 0=no)
iobs=appsettings.iobs.Value;
% Long run prior option
lrp=appsettings.lrp.Value;
% create H matrix for the long run priors 
% now taken from excel loadH.m
% H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
% Scale up the variance of the prior of factor f
priorf=100;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;
    

% panel Bayesian VAR specific information: will be read only if VARtype=4
elseif VARtype==4
% choice of panel model 
% 1=OLS mean group estimator, 2=pooled estimator
% 3=random effect (Zellner and Hong), 4=random effect (hierarchical)
% 5=static factor approach, 6=dynamic factor approach
if appsettings.Meangroup.Value==1 panel=1;
elseif appsettings.PooledEstimator.Value==1 panel=2;
elseif appsettings.RandomEffectZellnerHong.Value==1 panel=3;
elseif appsettings.RandomEffectHierarchical.Value==1 panel=4;
elseif appsettings.StaticStructurefactor.Value==1 panel=5;
elseif appsettings.DynamicStructurefactor.Value==1 panel=6;
    
end

% units; must be single sstring, with names separated by a space
unitnames=appsettings.unitnames.Value;
% total number of iterations for the Gibbs sampler
It=appsettings.It_panel.Value;
% number of burn-in iterations for the Gibbs sampler
Bu=appsettings.Bu_panel.Value;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;
% hyperparameter: autoregressive coefficient
ar=appsettings.ar_panel.Value;
% hyperparameter: lambda1
lambda1=appsettings.lambda1_panel.Value;
% hyperparameter: lambda2
lambda2=appsettings.lambda2_panel.Value;
% hyperparameter: lambda3
lambda3=appsettings.lambda3_panel.Value;
% hyperparameter: lambda4
lambda4=appsettings.lambda4_panel.Value;
% hyperparameter: s0
s0=appsettings.s0.Value;
% hyperparameter: v0
v0=appsettings.v0.Value;
% hyperparameter: alpha0
alpha0=appsettings.alpha0_panel.Value;
% hyperparameter: delta0
delta0=appsettings.delta0_panel.Value;
% hyperparameter: gama
gama=appsettings.gama_panel.Value;
% hyperparameter: a0
a0=appsettings.a0.Value;
% hyperparameter: b0
b0=appsettings.b0.Value;
% hyperparameter: rho
rho=appsettings.rho.Value;
% hyperparameter: psi
psi=appsettings.psi.Value;



% Stochastic volatility BVAR information: will be read only if VARtype=5

elseif VARtype==5
% choice of stochastic volatility model 
% 1=standard, 2=random scaling, 3=large BVAR
if appsettings.Standard.Value==1 stvol=1;
elseif appsettings.RandomInertia.Value==1 stvol=2;
elseif appsettings.LargeVAR.Value==1 stvol=3;
elseif appsettings.Stochastictrend.Value==1 stvol=4;
elseif appsettings.VARcoefficientstime.Value==1 tvbvar=1; VARtype=6;
elseif appsettings.Generaltime.Value==1 tvbvar=2; VARtype=6;
end

favar.FAVAR=0;

ar=appsettings.ar.Value;
PriorExcel=appsettings.PriorExcel.Value; % set to 1 if you want individual priors, 0 for default
priorsexogenous=0;
if appsettings.priorexogenous.Value(1:2)=='Ex' priorsexogenous=1; end% set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
lambda1=appsettings.lambda1.Value;
% hyperparameter: lambda2
lambda2=appsettings.lambda2.Value;
% hyperparameter: lambda3
lambda3=appsettings.lambda3.Value;
% hyperparameter: lambda4
lambda4=0.2;
%if priorsexogenous==0 lambda4=100; end
% hyperparameter: lambda5
lambda5=appsettings.lambda5.Value;
 
% total number of iterations for the Gibbs sampler
It=appsettings.It.Value;
% number of burn-in iterations for the Gibbs sampler
Bu=appsettings.Bu.Value;
% hyperparameter optimisation by grid search (1=yes, 0=no)
hogs=0;
if appsettings.hogs.Value(1:2)=='Ye' hogs=1; end;
% block exogeneity (1=yes, 0=no)
bex=0;
if appsettings.bex.Value(1:2)=='Ye' bex-1; end
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
pickf=20;

% hyperparameter: alpha0
alpha0=appsettings.alpha0.Value;
% hyperparameter: delta0
delta0=appsettings.delta0.Value;
% hyperparameter: gama
gamma=appsettings.gamma.Value;
% hyperparameter: gamma0
gamma0=appsettings.gamma0.Value;
% hyperparameter: zeta0
zeta0=appsettings.zeta0.Value;
% calculate IRFs for every sample period (1=yes, 0=no)
alltirf=appsettings.alltirf.Value;

% for code to run
if VARtype==6
    favar.FAVAR=0;
    ar=0;
    PriorExcel=0;
    priorsexogenous=1;
    lambda4=100;
end


% Time-varying BVAR information: will be read only if VARtype=6
%elseif VARtype==6
% choice of time-varying BVAR model 
% 1=time-varying coefficients, 2=general time-varying
%tvbvar=2;
% calculate IRFs for every sample period (1=yes, 0=no)
%alltirf=1;
% hyperparameter: gama
%gamma=0.85;
% hyperparameter: alpha0
%alpha0=0.001;
% hyperparameter: delta0
%delta0=0.001;
% just for the code to run (do not touch)
%ar=0;
%PriorExcel=0;
%priorsexogenous=1;
%lambda4=100;
%end

%% Mixed frequency VAR will be read only if VARtype == 7
elseif VARtype==7
% selected prior
% 11=Minnesota (univariate AR), 12=Minnesota (diagonal VAR estimates), 13=Minnesota (full VAR estimates)
% 21=Normal-Wishart(S0 as univariate AR), 22=Normal-Wishart(S0 as identity)
% 31=Independent Normal-Wishart(S0 as univariate AR), 32=Independent Normal-Wishart(S0 as identity)
% 41=Normal-diffuse
% 51=Dummy observations
if appsettings.BayesianVARpriors.Value(1:2)=='Mi' prior=11;
elseif appsettings.BayesianVARpriors.Value(1:7)=='NormalW' prior=21;
elseif appsettings.BayesianVARpriors.Value(1:2)=='In' prior=31;
elseif appsettings.BayesianVARpriors.Value(1:7)=='NormalD' prior=41;
elseif appsettings.BayesianVARpriors.Value(1:2)=='Du' prior=51;
elseif appsettings.BayesianVARpriors.Value(1:2)=='De' prior=61;
end

% hyperparameter: autoregressive coefficient
ar=appsettings.ar.Value; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
% switch to Excel interface
PriorExcel=appsettings.PriorExcel.Value; % set to 1 if you want individual priors, 0 for default
%switch to Excel interface for exogenous variables
priorsexogenous=0;
if appsettings.priorexogenous.Value(1:2)=='Ex' priorsexogenous=1; end% set to 1 if you want individual priors, 0 for default
% hyperparameter: lambda1
lambda1=appsettings.lambda1.Value;
% hyperparameter: lambda2
lambda2=appsettings.lambda2.Value;
% hyperparameter: lambda3
lambda3=appsettings.lambda3.Value;
% hyperparameter: lambda4
lambda4=0.1;
if priorsexogenous==0 lambda4=100; end
    
%appsettings.lambda4.Value;
% hyperparameter: lambda5
lambda5=appsettings.lambda5.Value;
% hyperparameter: lambda6
%lambda6=appsettings.lambda6.Value;
% hyperparameter: lambda7
%lambda7=appsettings.lambda7.Value;
% Overall tightness on the long run prior
%lambda8=appsettings.lambda8.Value;
% total number of iterations for the Gibbs sampler
It=appsettings.It.Value;
% number of burn-in iterations for the Gibbs sampler
Bu=appsettings.Bu.Value;
% hyperparameter optimisation by grid search (1=yes, 0=no)
hogs=0;
if appsettings.hogs.Value(1:2)=='Ye' hogs=1; end;
% block exogeneity (1=yes, 0=no)
bex=0;
if appsettings.bex.Value(1:2)=='Ye' bex-1; end
% sum-of-coefficients application (1=yes, 0=no)
scoeff=appsettings.scoeff.Value;
% dummy initial observation application (1=yes, 0=no)
iobs=appsettings.iobs.Value;
% Long run prior option
lrp=appsettings.lrp.Value;
% create H matrix for the long run priors 
% now taken from excel loadH.m
% H=[1 1 0 0;-1 1 0 0;0 0 1 1;0 0 -1 1];
% how many monhtly forecast to do in the original MF-BVAR code. Can be replaced in the future with Fsample_end-Fsample_start from BEAR
Input.H = 7;                      
end





% Model options
% activate impulse response functions (1=yes, 0=no)
IRF=appsettings.IRF.Value;
% activate unconditional forecasts (1=yes, 0=no)
F=appsettings.F.Value;
% activate forecast error variance decomposition (1=yes, 0=no)
FEVD=appsettings.FEVD.Value;
% activate historical decomposition (1=yes, 0=no)
HD=appsettings.HD.Value;
HDall=1;
% activate conditional forecasts (1=yes, 0=no)
CF=appsettings.CF.Value;
% structural identification (1=none, 2=Choleski, 3=triangular factorisation, 4=sign restrictions)
IRFt=1;
if appsettings.Choleskifactorisation.Value==1 IRFt=2;
elseif appsettings.Triangularfactorisation.Value==1 IRFt=3;
elseif appsettings.Signrestrictions.Value==1 IRFt=4;
elseif appsettings.Proxy.Value==1 IRFt=5;
elseif appsettings.Proxysign.Value==1 IRFt=6;
end;

%Proxy VARs
    %save in strctident
    strctident.IRFt = IRFt; 

    if IRFt==4 || IRFt==6 % if IRFt==4||IRFt==6 specify correlated Shock and Instrument
    strctident.CorrelShock=''; % exact labelname of the shock defined in sign res values or sign res values (IV);;; 'noexist' if unspecified
    strctident.CorrelInstrument=''; % provide the IV variable in excel sheet IV;;; 'noexist' if unspecified
    strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
    end
    if IRFt==5 || IRFt==6 % if IRFt=5||IRFt==6; specify Instrument to identfy Shock
    strctident.Instrument=appsettings.Instrument.Value;
    strctident.startdateIV=appsettings.startdateIV.Value;
    strctident.enddateIV=appsettings.enddateIV.Value;
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
    %        strctident.Thin=appsettings.Thin.Value;
            strctident.Thin=10;
            strctident.prior_type_reduced_form=1; %1=flat NW as in Uhlig 2006, 2=normal wishart , related to the IV routine
    if appsettings.prior_type_reduced_form.Value(1:2)=='No' strctident.prior_type_reduced_form=2; end;
    
    strctident.Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
   if appsettings.Switchprobability.Value(1:2)=='No' strctident.Switchprobability=1; end;
    
    strctident.prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)
    if appsettings.prior_type_proxy.Value(1:2)=='No' strctident.prior_type_proxy=2; end;
    
        end
    end
    

  

% activate forecast evaluation (1=yes, 0=no)
Feval=0;
if appsettings.Feval.Value(1:2)=='Ye' Feval=1; end;
% type of conditional forecasts 
% 1=standard (all shocks), 2=standard (shock-specific)
% 3=tilting (median), 4=tilting (interval)
CFt=1;
if appsettings.Standardshockspecific.Value==1 CF1=2;
elseif appsettings.Tiltingmedian.Value==1 CF1=3;
elseif appsettings.Tiltinginterval.Value==1 CF1=4;
end    
% number of periods for impulse response functions
IRFperiods=appsettings.IRFperiods.Value;
% start date for forecasts (has to be an in-sample date; otherwise, ignore and set Fendsmpl=1)
Fstartdate=appsettings.Fstartdate.Value;
% end date for forecasts
Fenddate=appsettings.Fenddate.Value;
% start forecasts immediately after the final sample period (1=yes, 0=no)
% has to be set to 1 if start date for forecasts is not in-sample
Fendsmpl=0;
if appsettings.Fendsmpl.Value(1:2)=='Ye' Fendsmpl=1;end
% step ahead evaluation
hstep=appsettings.hstep.Value;
% window_size for iterative forecasting 0 if no iterative forecasting
window_size=appsettings.window_size.Value;
% evaluation_size as percent of window_size                                      <                                                                                    -
evaluation_size=appsettings.evaluation_size.Value;              
% confidence/credibility level for VAR coefficients
cband=appsettings.cband.Value;
% confidence/credibility level for impusle response functions
IRFband=appsettings.cband.Value;
% confidence/credibility level for forecasts
Fband=appsettings.cband.Value;
% confidence/credibility level for forecast error variance decomposition
FEVDband=appsettings.cband.Value;
% confidence/credibility level for historical decomposition
HDband=appsettings.cband.Value;