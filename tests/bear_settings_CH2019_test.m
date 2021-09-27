function s = bear_settings_CH2019_test(excelPath)

s = BEARsettings(2, 'ExcelPath', excelPath);

s.frequency=3;
s.startdate='1993m1';
s.enddate='2007m6';
s.varendo='EFFR_LW LIPM UNRATE LPPI BAA10YMOODY';
s.varexo='';
s.lags=12;
s.const=1;

s.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
s.results_sub='results_test_data_CH2019_temp';
s.results=1;
s.plot=0;
s.workspace=1;

s.favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)

s.prior=21; %the only prior possible with IRFt==5
s.ar=1; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
s.lambda1=0.1; %not used for CH replication as nwprior only for IRFt==5
s.lambda2=0.5;            %not used for Replication as the prior is of the normal wishart family
s.lambda3=1;
s.lambda4=100;
s.lambda5=0.001;
s.lambda6=1;
s.lambda7=0.1;
s.lambda8=1;
s.It=2000;
s.Bu=1000;
s.hogs=0;
s.bex=0;
s.scoeff=0;
s.iobs=0;
s.lrp=0;
s.priorf=100;

s.IRF=1;
s.IRFperiods=48;
s.F=1;
s.FEVD=1;
s.HD=1;
s.HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
s.CF=1;

s.IRFt=5;

s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
s.strctident.Instrument='MHF'; % specify Instrument to identfy Shock
s.strctident.startdateIV='1993m1';
s.strctident.enddateIV='2007m6';
s.strctident.Thin=10;
s.strctident.prior_type_reduced_form=2; %1=flat (standard), 2=normal wishart , related to the IV routine
s.strctident.Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
s.strctident.prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)

s.Feval=1;
s.CFt=2;
s.Fstartdate='2006m8';
s.Fenddate='2007m6';
s.Fendsmpl=0;
s.hstep=1;
s.window_size=0;
s.evaluation_size=0.5;
s.cband=0.95;
s.IRFband=0.9;
s.Fband=0.68;
s.FEVDband=0.95;
s.HDband=0.68;