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

    %% BLOCK 1: MODEL ESTIMATION
    [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,Y,Ymat,Xmat,Xdot,theta_gibbs,sigma_gibbs,Xi,N,n,m,p,k,T,q,d1,d2,d3,d4,d5] = driver_estimation_panel_factor_static(data_endo,data_exo,const,lags,It,Bu,cband,alpha0,delta0,pick,pickf);

    %% BLOCK 2: IRFS
    % impulse response functions (if activated)
    if IRF==1
      % estimate the IRFs
      [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
        bear.panel5irf(Y,Xdot,theta_gibbs,sigma_gibbs,Xi,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,favar);

      % display the results
      bear.panel5irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
    end

    %% BLOCK 3: FORECASTS

    % forecasts (if activated)
    if F==1
      % estimate the forecasts
      [forecast_record, forecast_estimates]=...
        bear.panel5forecast(N,n,p,data_endo_a,data_exo_p,It,Bu,theta_gibbs,sigma_gibbs,Xi,Fperiods,const,Fband);

      % display the results
      bear.panel5fdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
    end

    %% BLOCK 4: FEVD

    % FEVD (if activated)
    if FEVD==1
      % estimate the FEVD
      [fevd_record, fevd_estimates]=bear.panel5fevd(N,n,struct_irf_record,gamma_record,It,Bu,IRFperiods,FEVDband);

      % display the results
      bear.panel5fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
    end

    %% BLOCK 5: HISTORICAL DECOMPOSITION

    % historical decomposition (if activated)
    if HD==1
      % estimate historical decomposition
      [hd_record, hd_estimates]=bear.panel5hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,Xmat,N,n,m,p,k,T,HDband);

      % display the results
      bear.panel5hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
    end

    %% BLOCK 6: CONDITIONAL FORECASTS

    % conditional forecast (if activated)
    if CF==1
      % estimate conditional forecasts
      [cforecast_record, cforecast_estimates]=...
        bear.panel5cf(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,Xi,theta_gibbs,D_record,gamma_record,CFt,Fband);

      % display the results
      bear.panel5cfdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
      
    end

    %% BLOCK 7: DISPLAY OF THE RESULTS
    bear.panel5disp(n,N,m,p,k,T,d1,d2,d3,d4,d5,Ymat,Xdot,Units,endo,exo,const,Xi,theta_gibbs,theta_median,theta_std,theta_lbound,theta_ubound,sigma_gibbs,...
      sigma_median,D_estimates,gamma_estimates,alpha0,delta0,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,...
      stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names);
  end