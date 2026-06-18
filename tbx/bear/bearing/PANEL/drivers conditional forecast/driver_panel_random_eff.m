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

    %% BLOCK 1: MODEL ESTIMATION
    [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median,Yi, Xi, beta_gibbs,sigma_gibbs, N,n,m,p,k,T,q] = driver_estimation_panel_random_eff(data_endo,data_exo,const,lags,lambda1,It,Bu,cband);

    %% BLOCK 2: IRFS
    % impulse response functions (if activated)
    IRFt = 1;
    if IRF==1
      if IRFt==1 || IRFt==2 || IRFt==3
        signrestable=[];
        signresperiods=[];
      end

      % estimate the IRFs
      [irf_record, D_record, gamma_record, struct_irf_record, irf_estimates, D_estimates, gamma_estimates, strshocks_record, strshocks_estimates]=...
          bear.panel3irf(Yi,Xi,beta_gibbs,sigma_gibbs,It,Bu,IRFperiods,IRFband,N,n,m,p,k,T,IRFt,signrestable,signresperiods,favar);

      % display the results
      bear.panel3irfdisp(N,n,Units,endo,irf_estimates,strshocks_estimates,IRFperiods,IRFt,stringdates1,T,decimaldates1,pref);
    end

    % estimate IRFs for exogenous variables
    if isempty(data_exo)~=1 %%%%%&& m>0
        [~,exo_irf_estimates]=bear.irfexo(beta_gibbs,It,Bu,IRFperiods,IRFband,n,m,p,k,N);

        bear.irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref, N, Units);
    end

    %% BLOCK 3: FORECASTS

    % forecasts (if activated)
    % if F==1
    %   % estimate the forecasts
    %   [forecast_record, forecast_estimates]=...
    %     bear.panel3forecast(N,n,p,k,data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,const,Fband,Fstartlocation,favar);

    %   % display the results
    %   bear.panel3fdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);

    % end

    %% BLOCK 4: FEVD

    % FEVD (if activated)
    % if FEVD==1
    %   % estimate the FEVD
    %   [fevd_record, fevd_estimates]=bear.panel3fevd(N,struct_irf_record,gamma_record,It,Bu,IRFperiods,n,FEVDband);

    %   % display the results
    %   bear.panel3fevddisp(n,N,Units,endo,fevd_estimates,IRFperiods,pref);
    % end

    % historical decomposition (if activated)
    % if HD==1
    %   % estimate historical decomposition
    %   [hd_record, hd_estimates]=bear.panel3hd(beta_gibbs,D_record,strshocks_record,It,Bu,Yi,Xi,N,n,m,p,k,T,HDband);

    %   % display the results
    %   bear.panel3hddisp(N,n,T,Units,endo,hd_estimates,stringdates1,decimaldates1,pref);
    % end

    %% BLOCK 6: CONDITIONAL FORECASTS

    % conditional forecast (if activated)
    if CF==1
      % estimate conditional forecasts
      [nconds, cforecast_record, cforecast_estimates]=...
        cf_driver_NoCrossSectional(N,n,m,p,k,q,cfconds,cfshocks,cfblocks,data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,const,beta_gibbs,D_record,gamma_record,CFt,Fband);

      % display the results
      bear.panel3cfdisp(N,n,T,Units,endo,Yi,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref,nconds);
      
    end

    %% BLOCK 7: DISPLAY OF THE RESULTS
    % bear.panel3disp(n,N,m,p,k,T,Yi,Xi,Units,endo,exo,const,beta_gibbs,beta_median,beta_std,beta_lbound,beta_ubound,sigma_gibbs,...
    %                 sigma_median,D_estimates,gamma_estimates,lambda1,startdate,enddate,forecast_record,forecast_estimates,Fcperiods,stringdates3,...
    %                 Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names);
  end