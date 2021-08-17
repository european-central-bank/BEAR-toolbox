function s = bear_settings_test(excelPath)

s = BEARsettings(2, 'ExcelPath', excelPath);
s.frequency=2;
s.startdate='1974q1';
s.enddate='2014q4';
s.varendo='DOM_GDP DOM_CPI STN';
s.varexo='';
s.lags=4;
s.const=1;
s.pref.datapath = bearroot(); % fileparts(mfilename('fullpath')); % next to settings
s.pref.results_path = fullfile(fileparts(mfilename('fullpath')),'results');
s.pref.results_sub='results_test_data_temp';
s.pref.results=1;
s.pref.plot=0;
s.pref.pref=0;
s.pref.workspace=1;

s.favar.FAVAR=0; % augment VAR model with factors (1=yes, 0=no)

s.prior=12;
s.ar=0.8;
s.PriorExcel=0; % set to 1 if you want individual priors, 0 for default
s.priorsexogenous=0; % set to 1 if you want individual priors, 0 for default
s.lambda1=0.1;
s.lambda2=0.5;
s.lambda3=1;
s.lambda4=100;
s.lambda5=0.001;
s.lambda6=1;
s.lambda7=0.1;
s.lambda8=1;
s.priorf=100;
s.It=2000;
s.Bu=1000;
s.hogs=0;
s.bex=0;
s.scoeff=0;
s.iobs=0;
s.lrp=0;

s.IRF=1;
s.F=1;
s.FEVD=1;
s.HD=0;
s.CF=1;
s.IRFt=4;

s.strctident.MM=0; % option for Median model (0=no (standard), 1=yes)
s.strctident.CorrelShock=''; % exact labelname of the shock defined in one of the "...res values" excel sheets, otherwise if the shock is not identified yet name it 'CorrelShock'
s.strctident.CorrelInstrument=''; % provide the IV variable in excel sheet "IV"

s.Feval=1;
s.CFt=1;
s.IRFperiods=20;
s.Fstartdate='2014q1';
s.Fenddate='2016q4';
s.Fendsmpl=0;
s.hstep=1;
s.window_size=0;
s.evaluation_size=0.5;
s.cband=0.95;
s.IRFband=0.95;
s.Fband=0.95;
s.FEVDband=0.95;
s.HDband=0.95;