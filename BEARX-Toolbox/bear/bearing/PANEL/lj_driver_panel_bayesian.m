clear all
close all

panel = 3;

run("driver_init.m");

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

    this.Settings = struct();
    this.Settings.lambda1 = lambda1;
    this.Settings.lambda3 = lambda3;
    this.Settings.lambda4 = lambda4;
    this.Settings.ar      = ar;
    this.Settings.priorexo = priorexo;

    longY = data_endo;
    longX = data_exo;
    longZ = [];

keyboard
    % get sampler
    outSampler = lj_panel_bayesian_smpl(this, meta, {longY, longX, longZ});
    % call sampler to get one gibbs sample
    smpl = outSampler();

    % get drawer
    [drawerH, timelessDrawerH] = lj_panel_rand_eff_drawer(meta);

    % call drawer
    drw = drawerH(smpl, Fperiods);
    tl_drw = timelessDrawerH(smpl,Fstartlocation,Fperiods);


    % % get data in X and Y format to have something to play with
    % [Y, X] = lj_get_XY_format(data_endo,data_exo,const,numLags);

    % % get B and Sigma in the matrix format
    % [A, C, D, Sigma] = lj_panel_rand_eff_drawer(smpl,numCountries,numEndog,numLags,numExog, IRFt);

    % test if it works
    % eps = Y - X*B;

    % lj_simulate(Y,X,B,Fperiods,numLags,numCountries,numEndog,numExog);
  end