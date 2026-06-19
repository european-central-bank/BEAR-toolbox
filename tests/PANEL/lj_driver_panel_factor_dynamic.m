clear all
close all

panel = 6;

run("driver_init.m");
% it is too slow, so I am decreasing number of draws havily just to get some results
% It = 200; % orig 2000
% Bu = 100; % orig 1000

rng('default');

for iteration=1:numt % beginning of forecasting loop
  if window_size>0
      data_endo = data_endo_full(iteration:window_size+iteration,:);

      Fstartlocation1 = find(strcmp(names(1:end,1),startdateini))+iteration-1;

      startdate = char(names(Fstartlocation1,1));
      
      Fendlocation = find(strcmp(names(1:end,1),startdateini))+window_size+iteration-1;

      enddate = char(names(Fendlocation,1));

      if F>0
        Fstartdate=char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+1,1));

        Fenddate=char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+hstep,1));
      end

      [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4]...
        =bear.gensamplepan(startdate,enddate,Units,opts.panel,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,pref,ar,0,0, n);

      % generate the strings and decimal vectors of dates
      [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation]=bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);
    end

    %% BLOCK 1: MODEL ESTIMATION
    % [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,Ymat,y, Xtilde,theta_gibbs,sigma_gibbs,sigmatilde_gibbs,Zeta_gibbs,phi_gibbs,B_gibbs,Xi,thetabar,N,n,m,p,T,d,k,q,d1,d2,d3,d4,d5,acceptrate] = driver_estimation_panel_factor_dynamic(data_endo,data_exo,const,lags,It,Bu,cband,alpha0,delta0,pick,pickf,rho,gamma,a0,b0,psi);

    % compute preliminary elements 
    % TODO
    % currently I call this function again in sampler. Not efficient, but I need here Xi and thetabar
    % [Ymat,Xmat,N,n,m,p,T,k,q,h]=bear.panel6prelim(data_endo,data_exo,const,lags);
    % % obtain prior elements
    % [~,~,~,~,~,~,~,~,~,~,~,Xi,~,~,thetabar,~,~,~,~,~]=bear.panel6prior(N,n,p,m,k,q,h,T,Ymat,Xmat,rho,gamma);

    % get dimensions
    numLags       = lags;
    numCountries  = size(data_endo,3);
    numEndog      = size(data_endo,2);
    numExog       = size(data_exo,2);
    if const
      numExog     = numExog+1;
    end

    meta = struct();
    meta.flagConst    = const;
    meta.numLags      = numLags;
    meta.numCountries = numCountries;
    meta.numEndog     = numEndog;
    meta.numExog      = numExog;
    meta.Bu           = 20; %Bu; Temporary use some small number to get some results
    meta.horizon      = 10;

    this.Settings = struct();
    % hyper = struct();
    this.Settings.alpha0 = alpha0;
    this.Settings.delta0 = delta0;
    this.Settings.rho    = rho;
    this.Settings.gamma  = gamma;
    this.Settings.a0     = a0;
    this.Settings.b0     = b0;
    % hyper.psi    = psi; % not used in the function

    longY = data_endo;
    longX = data_exo;
    longZ = [];

    % get sampler
    outSampler = lj_panel_factor_dynamic_smpl(this, meta, longY, longX, longZ);

    % get one gibbs sample
    smpl = outSampler();


    % get dimensions
    numCountries = size(data_endo,3);
    numEndog = size(data_endo,2);
    numExog = size(data_exo,2);
    if const
      numExog = numExog+1;
    end
    
    %% Construct draw for beta from sample for Flocation:Fstartlocation-1+Fperiods
    Flocation = Fstartlocation;
    Fperiods  = 10;
    meta.IRFperiods = 10;
    keyboard
    % get drawer
    [indDrawer, uncondDrawer] = lj_panel_factor_dynamic_drawer(this, meta);

    % call drawer
    indDrw = indDrawer(smpl);
    uncondDrw = uncondDrawer(smpl,Fstartlocation,Fperiods);

    
  end