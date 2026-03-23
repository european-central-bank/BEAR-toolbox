run('SV_presettings.m');

stvol = 3;

rng('default')

for iteration=1:numt % beginning of forecasting loop
    if window_size>0
%         data_endo = data_endo_full(iteration:window_size+iteration,:);
        Fstartlocation1 = find(strcmp(names(1:end,1),startdateini))+iteration-1;
        startdate = char(names(Fstartlocation1,1));
        Fendlocation = find(strcmp(names(1:end,1),startdateini))+window_size+iteration-1;
        enddate = char(names(Fendlocation,1));
        if F>0
            Fstartdate = char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+1,1));
            Fenddate = char(stringdatesforecast(find(strcmp(stringdatesforecast(1:end,1),enddate))+hstep,1));
        end
            [names,data,data_endo,data_endo_a,data_endo_c,data_endo_c_lags,data_exo,data_exo_a,data_exo_p,data_exo_c,data_exo_c_lags,Fperiods,Fcomp,Fcperiods,Fcenddate,ar,priorexo,lambda4,favar]...
                = bear.gensample(startdate,enddate,VARtype,Fstartdate,Fenddate,Fendsmpl,endo,exo,frequency,lags,F,CF,ar,lambda4,PriorExcel,priorsexogenous,pref,favar,IRFt, n);

        % generate the strings and decimal vectors of dates
        [decimaldates1,decimaldates2,stringdates1,stringdates2,stringdates3,Fstartlocation,Fendlocation] =  ...
                    bear.gendates(names,lags,frequency,startdate,enddate,Fstartdate,Fenddate,Fcenddate,Fendsmpl,F,CF,favar);
    end

    %% BLOCK 1: OLS ESTIMATES
    run('SV_ols.m');

    %% BLOCK 2: PRIOR EXTENSIONS, estimation
    % implement any dummy observation extensions that may have been selected
    [B0, phi0, G, I_o, omega, f0, upsilon0]=bear.stvol3prior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,T,k,q,gamma,priorexo);
    % run the Gibbs sampling algorithm to recover the posterior distributions
    [beta_gibbs, F_gibbs, L_gibbs, phi_gibbs, sigma_gibbs, lambda_t_gibbs, sigma_t_gibbs, sbar]=...
                        bear.stvol3gibbs(Xbart,Xt,yt,B0,phi0,alpha0,delta0,f0,upsilon0,betahat,sigmahat,gamma,G,I_o,omega,T,n,k,It,Bu,pick,pickf);
   
    % compute posterior estimates
    [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median, sigma_t_median, sigma_t_lbound, sigma_t_ubound,~]=stvol_estimates(beta_gibbs,sigma_gibbs,sigma_t_gibbs,n,T,cband);



    %% BLOCK 3: MODEL EVALUATION
    % display the VAR results
    
    bear.stvoldisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,sigma_t_median,sigma_t_lbound,sigma_t_ubound,gamma_median,X,Y,n,m,p,k,T,stvol,bex,ar,lambda1,lambda2,lambda3,lambda4,lambda5,gamma,alpha0,delta0,gamma0,zeta0,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref,PriorExcel);

    % compute and display the steady state results
    [ss_record]=bear.ssgibbs(n,m,p,k,X,beta_gibbs,It,Bu,favar);
    [ss_estimates]=bear.ssestimates(ss_record,n,T,cband);
    bear.ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref);
    
    %% BLOCK 4: IRF
    [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                        =bear.irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);
     [strshocks_estimates]=bear.strsestimates(ETA_record,n,T,IRFband);
      % display the results
      bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
    

    %% BLOCK 5: FORECASTS
    [forecast_record]=bear.forecaststvol3(data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma,sbar,Fstartlocation,Fperiods,n,p,k,const);
    % compute posterior estimates
    [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
    % display the results for the forecasts
    bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
    [Forecasteval]=bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,It,Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
    
    %% BLOCK 6: FEVD
    % run the Gibbs sampler to compute posterior draws
    [fevd_estimates]=bear.fevd(struct_irf_record,gamma_record,It,Bu,n,IRFperiods,FEVDband);
    bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
    
    %% BLOCK 7: historical decomposition
    % run the Gibbs sampler to compute posterior draws
    % [hd_record,favar]=bear.hdecomp_inc_exo(beta_gibbs,D_record,It,Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar);
    % % compute posterior estimates
    % [hd_estimates,favar]=bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
    % % display
    % bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
    
    %% BLOCK 8: conditional forecast
    % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
    [cforecast_record,cfstrshocks_record]=bear.cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
    % compute posterior estimates
    [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
    % display the results for the forecasts
    bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
    
    %% Block 9: saving results
    if pref.workspace==1
        if numt>1
            save(fullfile(pref.results_path, [ pref.results_sub Fstartdate '.mat'] )); % Save Workspace
        end
    end

    Fstartdate_rolling = [Fstartdate_rolling; Fstartdate];
end
if numt>1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rolling forecast evaluation
    % based on Francesca Loria
    % This Version: February 2018
    % Input:
    % 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
    %see later
    %gr_pf_windowSize = 19;
    %gr_pf_windowSize = round(evaluation_size*window_size);

    % 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
    %see later
    %rs_pf_windowSize = 25;
    %rs_pf_windowSize = round(evaluation_size*window_size);

    % 3. See Section 7. for Additional User Input required for Density Forecast Evaluation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    RMSE_rolling = [];
    for i = 1:numt
        Fstartdate=char(Fstartdate_rolling(i,:));
        output = char(strcat(fullfile(pref.results_path, [pref.results_sub Fstartdate '.mat'])));
        % load forecasts
        load(output,'forecast_estimates','forecast_record','varendo','names','frequency', 'Forecasteval')
        % load OLS AR forecast estimates as benchmark
        load(output,'OLS_forecast_estimates', 'OLS_Bhat', 'OLS_betahat', 'OLS_sigmahat', 'biclag')

        for j = 1:length(forecast_estimates)
            ols_forecasts(j,i)    = OLS_forecast_estimates{1,j}{1,1}(2,hstep); % assign median
            forecasts(j,i)        = forecast_estimates{j}(2,hstep); % assign median
            forecasts_dist(:,j,i) = sort(forecast_record{j,1}(:,1));     % assign entire distribution
        end
        sample=['f' Fstartdate];
        RMSE_rolling = [RMSE_rolling; Forecasteval.RMSE];
        Rolling.RMSE.(sample)=Forecasteval.RMSE;
        Rolling.MAE.(sample)=Forecasteval.MAE;
        Rolling.MAPE.(sample)=Forecasteval.MAPE;
        Rolling.Ustat.(sample)=Forecasteval.Ustat;
        Rolling.CRPS_estimates.(sample)=Forecasteval.CRPS_estimates;
        Rolling.S1_estimates.(sample)=Forecasteval.S1_estimates;
        Rolling.S2_estimates.(sample)=Forecasteval.S2_estimates;
    end

    %% Load Actual Data and Other Inputs
    actualdata = data(end-numt+1:end,:)';
    save('forecast_eval.mat','forecasts','actualdata');

    var_feval = endo;

    % Block size for the Inoue (2001) bootstrap procedure,
    % default is P^(1/3), where P is the size of the out-of-sample portion of
    % the available sample of size T+h
    P = length(forecasts);
    el = round(P^(1/3));

    % 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
    %gr_pf_windowSize = 19;
    gr_pf_windowSize = round(evaluation_size*P);

    % 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
    %rs_pf_windowSize = 25;
    %rs_pf_windowSize = round(evaluation_size*window_size);
    rs_pf_windowSize = round(evaluation_size*P);


    % 5. Number of bootstrap replications in the calculation of CV for the
    % Rossi-Sekhposyan test for multiple-step ahead forecast densities (h>1),
    % default is 300
    bootMC = 300;


    for ind_feval=1:length(endo) %index of selected variable
        ind_deval=ind_feval;

        %Grid
        for ii=1:size(forecasts_dist(:,ind_feval(1),:),3)
            for jj=1:size(forecasts_dist(:,ind_feval(1),:),1)-1
                diff(jj) = squeeze(forecasts_dist(jj+1,ind_feval(1),ii) - forecasts_dist(jj,ind_feval(1),ii));
            end
            mdiff(ii) = mean(diff);
        end
        tdiff = max(mdiff);

        gridDF = min(floor(min(forecasts_dist(:,ind_feval(1),:)))):tdiff:max(ceil(max(forecasts_dist(:,ind_feval(1),:))));

        startdate = char(Fstartdate_rolling(1,:));
        enddate   = char(Fstartdate_rolling(end,:));
        [pdate,stringdate] = bear.genpdate(names,0,frequency,startdate,enddate);

        bear.RS_PF(names, endo, ind_deval, actualdata, forecasts, ind_feval, rs_pf_windowSize, pdate); % Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
        bear.RS_DF(actualdata, gridDF, Bu, forecasts_dist, ind_feval, ind_deval, hstep, el, bootMC); % Rossi-Sekhposyan (2016) Tests for Correct Specification of Forecast Densities
        bear.GR_PF(forecasts, ind_feval, ols_forecasts, actualdata, pdate,gr_pf_windowSize, biclag, endo); % Giacomini-Rossi JAE(2010) Fluctuation Test


    end %loop ind_feval
end

% option to save matlab workspace
if pref.workspace==1
    save( fullfile(pref.results_path, [pref.results_sub '.mat']) );
end