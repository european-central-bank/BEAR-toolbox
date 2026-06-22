function s = bear_settings_PANEL(excelPath)

if nargin < 1
    s = BEARsettings(4);
else
    s = BEARsettings(4, 'ExcelFile', excelPath);
end

s.frequency=2;
s.startdate='1971q1';
s.enddate='2014q1';
s.varendo='YER HICSA STN';
s.varexo='Oil';
s.lags=4;
s.const=1;
s.results_path = fullfile(pwd,'results');
s.results_sub='results_panel';
s.results=1;
s.plot=1;
s.workspace=1;

s.unitnames='US EA UK';

%Type of panel
s.panel="Random_hierarchical";

s.ar=0.8;
s.lambda1=0.1;
s.lambda2=0.5;
s.lambda3=1;
s.lambda4=100;

% total number of iterations for the Gibbs sampler
s.It=2000;
% number of burn-in iterations for the Gibbs sampler
s.Bu=1000;
% choice of retaining only one post burn iteration over 'pickf' iterations (1=yes, 0=no)
s.pick=0;
% frequency of iteration picking (e.g. pickf=20 implies that only 1 out of 20 iterations will be retained)
s.pickf=20;
% hyperparameter: autoregressive coefficient
s.s0=0.001;
% hyperparameter: v0
s.v0=0.001;
% hyperparameter: alpha0
s.alpha0=1000;
% hyperparameter: delta0
s.delta0=1;
% hyperparameter: gama
s.gamma=0.85;
% hyperparameter: a0
s.a0=1000;
% hyperparameter: b0
s.b0=1;
% hyperparameter: rho
s.rho=0.75;
% hyperparameter: psi
s.psi=0.1;

s.IRF=1;
s.F=1;
s.CF=0;
s.IRFt=4;
s.FEVD=1;
s.HD=1;

s.Feval=1;
s.CFt=1;
s.IRFperiods=20;
s.Fstartdate='2014q2';
s.Fenddate='2015q4';
s.Fendsmpl=1;
s.hstep=1;
s.window_size=0;
s.evaluation_size=0.5;
s.cband=0.66;
s.IRFband=0.66;
s.Fband=0.66;
s.FEVDband=0.66;
s.HDband=0.66;