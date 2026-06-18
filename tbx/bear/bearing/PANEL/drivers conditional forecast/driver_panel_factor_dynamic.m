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
    [theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,Ymat,y, Xtilde,theta_gibbs,sigma_gibbs,sigmatilde_gibbs,Zeta_gibbs,phi_gibbs,B_gibbs,Xi,thetabar,N,n,m,p,T,d,k,q,d1,d2,d3,d4,d5,acceptrate] = driver_estimation_panel_factor_dynamic(data_endo,data_exo,const,lags,It,Bu,cband,alpha0,delta0,pick,pickf,rho,gamma,a0,b0,psi);

    %% BLOCK 2: IRFS
    % impulse response functions (if activated)
    if IRF==1
      % estimate the IRFs
      [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
        bear.panel6irf(y,Xtilde,theta_gibbs,sigma_gibbs,B_gibbs,Xi,It,Bu,IRFperiods,IRFband,IRFt,rho,thetabar,N,n,m,p,T,d,favar);

      % display the results
      bear.panel6irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
    end

    %% BLOCK 3: FORECASTS

    % forecasts (if activated)
    % if F==1
    %   % estimate the forecasts
    %   [forecast_record, forecast_estimates]=...
    %     bear.panel6forecast(const,data_exo_p,Fstartlocation,It,Bu,data_endo_a,p,B_gibbs,sigmatilde_gibbs,N,n,phi_gibbs,theta_gibbs,Zeta_gibbs,Fperiods,d,rho,thetabar,gamma,Xi,Fband);

    %   % display the results
    %   bear.panel6fdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref)
    % end

    % %% BLOCK 4: FEVD

    % % FEVD (if activated)
    % if FEVD==1
    %   % estimate the FEVD
    %   [fevd_record, fevd_estimates]=bear.panel6fevd(N,n,T,struct_irf_record,gamma_record,It,Bu,IRFperiods,FEVDband);

    %   % display the results
    %   bear.panel6fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
    % end

    % %% BLOCK 5: HISTORICAL DECOMPOSITION

    % % historical decomposition (if activated)
    % if HD==1
    %   % estimate historical decomposition
    %   [hd_record, hd_estimates]=bear.panel6hd(Xi,theta_gibbs,D_record,strshocks_record,It,Bu,Ymat,N,n,m,p,k,T,d,HDband);

    %   % display the results
    %   bear.panel6hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
    % end

    %% BLOCK 6: CONDITIONAL FORECASTS

    % conditional forecast (if activated)
    if CF==1
      [cforecast_record, cforecast_estimates]=...
        cf_driver_CrossSectionalDynamic(N,n,m,p,k,d,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,Xi,data_exo_p,theta_gibbs,B_gibbs,phi_gibbs,Zeta_gibbs,sigmatilde_gibbs,Fstartlocation,Ymat,rho,thetabar,gamma,CFt,Fband);

      % display the results
      bear.panel6cfdisp(N,n,T,Units,endo,Ymat,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
      
    end

    %% BLOCK 7: DISPLAY OF THE RESULTS
    % bear.panel6disp(n,N,m,p,k,T,d1,d2,d3,d4,d5,d,Ymat,Xtilde,Units,endo,exo,const,Xi,theta_median,theta_std,theta_lbound,theta_ubound,sigma_median,...
    %   D_estimates,gamma_estimates,alpha0,delta0,gamma,a0,b0,rho,psi,acceptrate,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,...
    %   stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,IRF,IRFt,pref,names);
  end