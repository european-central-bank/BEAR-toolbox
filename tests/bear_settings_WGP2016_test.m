function s = bear_settings_WGP2016_test(excelPath)

s = BEARsettings(2, 'ExcelPath', excelPath);

s.frequency=3;
s.startdate='2014m5';
s.enddate='2018m12';
s.varendo='hicp gdp app 10y stockindex';
s.varexo='';
s.lags=2;
s.const=1;
s.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
s.results_sub='results_test_data_WGP2016_temp';
s.results=1;
s.plot=0;
s.workspace=1;

s.favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)

s.prior=41;
s.ar=0.8; % this sets all AR coefficients to the same prior value (if PriorExcel is equal to 0)
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
s.lambda1=1000; % quasi-flat (diffuse) normal-wishart prior here, in the spirit of Uhlig (2005)
s.lambda2=0.5;
s.lambda3=1;
s.lambda4=1;
s.lambda5=0.001;
s.lambda6=1;
s.lambda7=0.1;
s.lambda8=1;
s.It=5000;
s.Bu=1000;
s.hogs=0;
s.bex=0;
s.scoeff=0;
s.iobs=0;
s.lrp=0;
s.priorf=100;

s.IRF=1;
s.IRFperiods=36;
s.F=0;
s.FEVD=0;
s.HD=0;
s.HDall=0;%if we want to plot the entire decomposition, all contributions (includes deterministic part)HDall
s.CF=0;
s.IRFt=4;

s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
s.strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
s.strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"
s.Feval=0;
s.CFt=1;
s.Fstartdate='2014q1';
s.Fenddate='2016q4';
s.Fendsmpl=0;
s.hstep=1;
s.window_size=0;
s.evaluation_size=0.5;
s.cband=0.95;
s.IRFband=0.68;
s.Fband=0.68;
s.FEVDband=0.68;
s.HDband=0.68;