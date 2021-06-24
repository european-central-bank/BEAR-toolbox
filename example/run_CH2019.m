opts = BEARsettings(2, fullfile(fullfile(bearroot(),'replications', 'data_CH2019.xlsx')));

opts.frequency = 3;
opts.startdate = '1993m1';
opts.enddate='2007m6';

opts.varendo='EFFR_LW LIPM UNRATE LPPI BAA10YMOODY';
opts.lags = 12;
opts.const = 1;

opts.pref.results_path = fullfile(pwd, 'results');
opts.pref.results_sub = 'results_CH2019';

opts.prior = 21;
opts.ar = 1;

opts.lambda1 = 0.1;
opts.lambda4 = 100;
opts.lambda5 = 0.001;
opts.It = 2000;
opts.Bu = 1000;

opts.IRFperiods = 48;

opts.CF = 1;
opts.IRFt = 5;

opts.strctident.MM=0;
opts.strctident.Instrument='MHF';
opts.strctident.startdateIV='1993m1';
opts.strctident.enddateIV='2007m6';
opts.strctident.Thin=10;
opts.strctident.prior_type_reduced_form=2;
opts.strctident.Switchprobability=0;
opts.strctident.prior_type_proxy=1;

opts.Feval = 1;
opts.CFt = 2;
opts.Fstartdate='2006m8';
opts.Fenddate='2007m6';
opts.IRFband = 0.9;
opts.Fband = 0.68;
opts.FEVDband=0.95;
opts.HDband  = 0.68;

BEARmain(opts)