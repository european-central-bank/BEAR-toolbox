opts = BEARsettings(2,  fullfile(fullfile(bearroot(),'replications', 'data_BBE2005.xlsx')));

opts.frequency = 3;
opts.startdate = '1959m2';
opts.enddate = '2001m8';

opts.varendo='factor1 factor2 factor3 FYFF';
opts.varexo = '';

opts.lags = 13;
opts.const = 0;

opts.pref.results_path = fullfile(pwd, 'results');
opts.pref.results_sub='results_BBE2005';

opts.pref.plot=1;

opts.favar.FAVAR = 1;

opts.favar.transformation=0; 
opts.favar.transform_endo=''; 

opts.favar.numpc=3;

opts.favar.slowfast=1;  % assign variables in the excel sheet 'factor data' in the 'block' row to "slow" or "fast"

opts.favar.onestep=1;
opts.favar.thin=1;
opts.favar.L0=1;
opts.favar.a0=3;
opts.favar.b0=0.001;

opts.favar.blocks=0;

opts.favar.plotX='IP PUNEW FYGM3 FYGT5 FMFBA FM2 EXRJAN PMCP IPXMCA GMCQ GMCDQ GMCNQ LHUR PMEMP LEHCC HSFR PMNO FSDXP HHSNTN';
opts.favar.plotXshock='FYFF';

opts.favar.levels=1;
opts.favar.retransres=1; 
opts.favar.IRF.plot=1;
opts.favar.FEVD.plot=1;
opts.favar.HD.plot=0;

opts.prior=21;
opts.ar=0.8;
opts.PriorExcel=0;
opts.priorsexogenous=0;
opts.lambda1=1;
opts.lambda2=0.5;
opts.lambda3=1;
opts.lambda4=1;
opts.lambda5=0.001;
opts.lambda6=1;
opts.lambda7=0.1;
opts.lambda8=1;
opts.It=10000;
opts.Bu=2000;
opts.hogs=0;
opts.bex=0;
opts.scoeff=0;
opts.iobs=0;
opts.lrp=0;
opts.priorf=100;

opts.IRF=1;
opts.IRFperiods=48;
opts.F=0;
opts.FEVD=0;
opts.HD=0; 
opts.HDall=1;
opts.CF=0;
opts.IRFt=2;

opts.Feval=0;
opts.CFt=1;
opts.Fstartdate='2014q1';
opts.Fenddate='2016q4';
opts.Fendsmpl=0;
opts.hstep=1;
opts.window_size=0;
opts.evaluation_size=0.5;
opts.cband=0.9;
opts.IRFband=0.9;
opts.Fband=0.9;
opts.FEVDband=0.9;
opts.HDband=0.9;

BEARmain(opts)