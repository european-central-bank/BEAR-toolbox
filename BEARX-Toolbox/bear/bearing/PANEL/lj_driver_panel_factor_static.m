clear all
close all

panel = 5;

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

    numLags = lags;

    % get sampler
    outSampler = lj_panel_factor_static_smpl(data_endo,data_exo,const,numLags,alpha0,delta0,Bu);
    % call sampler to get one gibbs sample
    smpl = outSampler();
    % get data in X and Y format to have something to play with
    [Y, X] = lj_get_XY_format(data_endo,data_exo,const,numLags);

    % get dimensions
    numCountries = size(data_endo,3);
    numEndog = size(data_endo,2);
    numExog = size(data_exo,2);
    if const
      numExog = numExog+1;
    end

    % get B and Sigma in the matrix format
    [B,Sigma] = lj_panel_factor_static_drawer(smpl,numCountries,numEndog,numLags,numExog);

    % test if it works
    eps = Y - X*B;

    lj_simulate(Y,X,B,Fperiods,numLags,numCountries,numEndog,numExog);
 
  end