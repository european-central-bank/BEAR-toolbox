clear all
close all

panel = 1;

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

    %% BLOCK 1: MODEL ESTIMATION
    [bhat, sigmahatb, sigmahat, Y, X,N,n,m,p,k,q,T] = driver_estimation_panel_ols(data_endo,data_exo,const,lags);

    % plot a first set of results
    % bear.panel1plot(endo,Units,X,Y,N,n,m,p,k,T,bhat,decimaldates1,stringdates1,pref);

    %% BLOCK 2: IRFS
    % impulse response functions (if activated)
    if IRF==1

      % estimate the IRFs
      [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates]=bear.panel1irf(Y,X,N,n,m,p,k,q,IRFt,bhat,sigmahatb,sigmahat,IRFperiods,IRFband);

      % display the results
      bear.panel1irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
      
    end

    %% BLOCK 3: FORECASTS

    % forecasts (if activated)
    if F==1
      % estimate the forecasts
      [forecast_estimates]=bear.panel1forecast(sigmahat,bhat,k,n,const,data_exo_p,Fperiods,N,data_endo_a,p,T,m,Fband);

      % display the results
      bear.panel1fdisp(N,n,T,Units,endo,Y,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
    end

    %% BLOCK 4: FEVD

    % FEVD (if activated)
    if FEVD==1
      % estimate FEVD and display the results
      [fevd_estimates]=bear.panel1fevd(N,n,irf_estimates,IRFperiods,gamma,Units,endo,pref);
    end

    %% BLOCK 5: HISTORICAL DECOMPOSITION

    % historical decomposition (if activated)
    if HD==1
      % estimate historical decomposition and display the results
      [hd_estimates]=bear.panel1hd(Y,X,N,n,m,p,T,k,D,bhat,endo,Units,decimaldates1,stringdates1,pref);
    end

    
    %% BLOCK 7: DISPLAY OF THE RESULTS
%     bear.panel1disp(X,Y,n,N,m,p,T,k,q,const,bhat,sigmahat,sigmahatb,Units,endo,exo,gamma_estimates,D_estimates,startdate,...
%       enddate,Fstartdate,Fcenddate,Fcperiods,Feval,Fcomp,data_endo_c,forecast_estimates,stringdates3,cband,pref,IRF,IRFt,names);
  end