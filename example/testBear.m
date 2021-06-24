opts = BEARsettings(2, fullfile(fullfile(bearroot(),'replications', 'data_.xlsx')));

opts.pref.results_path = fullfile(pwd, 'results');
opts.pref.results_sub = 'results';

opts.prior = 12;
opts.lambda1 = 0.1;
opts.lambda4 = 100;
opts.lambda5 = 0.001;
opts.It = 2000;
opts.Bu = 1000;
opts.HD = 0;
opts.CF = 1;
opts.Feval = 1;
opts.IRFband = 0.68;
opts.HDband  = 0.95;

BEARmain(opts)