
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Grand loop 2: BVAR model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this is the part of the code that will be run if the selected VAR model is a BVAR
if VARtype==2

    %% BLOCK 1: OLS ESTIMATES

    % preliminary OLS VAR and univariate AR estimates
    if opts.prior~=61
        [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
    elseif opts.prior==61 % other preliminary steps for Mean-adjusted model (prior=61)
        [Y, X, Z, n, m, p, T, k1, k3, q1, q2, q3]=bear.TVEmaprelim(data_endo,data_exo,const,lags,regimeperiods,names);
        k=k1; %for some rountines
        q=q1+q2;
        %m=0;
    end
    [arvar]=bear.arloop(data_endo,const,p,n);



    %% BLOCK 2: PRIOR EXTENSIONS

    % if hyperparameter optimisation has been selected, run the grid search
    if opts.hogs==1 && opts.PriorExcel==0
        % grid for the Minnesota
        if opts.prior==11||opts.prior==12||opts.prior==13
            [opts.ar, opts.lambda1, opts.lambda2, opts.lambda3, opts.lambda4, opts.lambda6, opts.lambda7]=bear.mgridsearch(X,Y,y,n,m,p,k,q,T,grid,arvar,sigmahat,data_endo,data_exo,priorexo,blockexo,const,H,opts);
           
            % grid for the normal- Wishart
        elseif opts.prior==21||opts.prior==22
            [opts.ar, opts.lambda1, opts.lambda3, opts.lambda4, opts.lambda6, opts.lambda7]=bear.nwgridsearch(X,Y,n,m,p,k,q,T,opts.lambda2,opts.lambda5,opts.lambda6,opts.lambda7,opts.lambda8,grid,arvar,data_endo,data_exo,opts.prior,priorexo,opts.hogs,opts.bex,const,opts.scoeff,opts.iobs,pref,opts.It,opts.Bu,opts.lrp,H);
        end
        % update record of results on Excel
        [estimationinfo] = bear.data.excelrecord1fcn(endo, exo, Units, opts);
    end

    % implement any dummy observation extensions that may have been selected
    [Ystar,ystar,Xstar,Tstar,Ydum,ydum,Xdum,Tdum]=bear.gendummy(data_endo,data_exo,Y,X,n,m,p,T,const,opts.lambda6,opts.lambda7,opts.lambda8,opts.scoeff,opts.iobs,opts.lrp,H);


    %% BLOCK 3: POSTERIOR DERIVATION

    % estimation of BVAR if a Minnesota prior has been chosen (i.e., prior has been set to 11,12 or 13)
    if opts.prior==11||opts.prior==12||opts.prior==13
        % set prior values
        [beta0,omega0,sigma]=bear.mprior(opts.ar,arvar,sigmahat,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,n,m,p,k,q,opts.prior,opts.bex,blockexo,priorexo);
        % obtain posterior distribution parameters
        [betabar,omegabar]=bear.mpost(beta0,omega0,sigma,Xstar,ystar,q,n);
        % run Gibbs sampling for the Minnesota prior
        if favar.FAVAR==0
            [beta_gibbs,sigma_gibbs]=bear.mgibbs(opts.It,opts.Bu,betabar,omegabar,sigma,q);
        elseif favar.FAVAR==1
            [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_mgibbs(opts.It,opts.Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,opts.ar,arvar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,m,p,k,opts.prior,opts.bex,blockexo,priorexo,Y,X,y);
        end
        % compute posterior estimates
        [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.mestimates(betabar,omegabar,sigma,q,cband);


        % estimation of BVAR if a normal-Wishart prior has been chosen (i.e., prior has been set to 21 or 22)
    elseif opts.prior==21||opts.prior==22
        if IRFt<=4
            % set prior values
            [B0,beta0,phi0,S0,opts.alpha0]=bear.nwprior(opts.ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,n,m,p,k,q,opts.prior,priorexo);
            % obtain posterior distribution parameters
            [Bbar,betabar,phibar,Sbar,alphabar,alphatilde]=bear.nwpost(B0,phi0,S0,opts.alpha0,Xstar,Ystar,n,Tstar,k);
            % run Gibbs sampling for the normal-Wishart prior
            if favar.FAVAR==0
                [beta_gibbs,sigma_gibbs]=bear.nwgibbs(opts.It,opts.Bu,Bbar,phibar,Sbar,alphabar,alphatilde,n,k);
            elseif favar.FAVAR==1
                [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_nwgibbs(opts.It,opts.Bu,Bhat,EPS,n,m,p,k,T,q,lags,data_endo,opts.ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,opts.prior,priorexo,const,data_exo,favar,Y,X);
            end
            % compute posterior estimates
            [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.nwestimates(betabar,phibar,Sbar,alphabar,alphatilde,n,k,cband);
        end


        % estimation of BVAR if an independent normal-Wishart prior has been chosen (i.e., prior has been set to 31 or 32)
    elseif opts.prior==31||opts.prior==32
        if IRFt<=4
            % set prior values
            [beta0,omega0,S0,opts.alpha0]=bear.inwprior(opts.ar,arvar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,n,m,p,k,q,opts.prior,opts.bex,blockexo,priorexo);
            % run Gibbs sampling for the mixed prior
            if favar.FAVAR==0
                [beta_gibbs,sigma_gibbs]=bear.inwgibbs(opts.It,opts.Bu,beta0,omega0,S0,opts.alpha0,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
            elseif favar.FAVAR==1
                [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_inwgibbs(opts.It,opts.Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,opts.ar,arvar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,m,p,k,opts.prior,opts.bex,blockexo,priorexo,Y,X,y,endo);
            end
            % compute posterior estimates
            [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.inwestimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
        end


        % estimation of BVAR if a normal-diffuse prior has been chosen (i.e., prior has been set to 41 or 42)
    elseif opts.prior==41
        if IRFt<=4
            % set prior values
            [beta0, omega0]=bear.ndprior(opts.ar,arvar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,n,m,p,k,q,opts.bex,blockexo,priorexo);
            % run Gibbs sampling for the normal-diffuse prior
            if favar.FAVAR==0
                if opts.lambda1>999 % switch to flat prior in this case
                    [beta_gibbs,sigma_gibbs]=bear.ndgibbstotal(opts.It,opts.Bu,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
                else
                    [beta_gibbs,sigma_gibbs]=bear.ndgibbs(opts.It,opts.Bu,beta0,omega0,Xstar,Ystar,ystar,Bhat,n,Tstar,q);
                end
            elseif favar.FAVAR==1
                if opts.lambda1>999 % switch to flat prior in this case
                    [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_ndgibbstotal(opts.It,opts.Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,X,Y,y,favar);
                else
                    [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_ndgibbs(opts.It,opts.Bu,Bhat,EPS,n,T,q,lags,data_endo,data_exo,const,favar,opts.ar,arvar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,m,p,k,opts.bex,blockexo,priorexo,Y,X,y,endo);
                end
            end
            % compute posterior estimates
            [beta_median, beta_std, beta_lbound, beta_ubound,sigma_median]=bear.ndestimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
        end

        % estimation of BVAR if a dummy observation prior has been chosen (i.e., prior has been set to 51, 52 or 53)
    elseif opts.prior==51
        % set 'prior' values (here, the dummy observations)
        [Ystar,Xstar,Tstar]=bear.doprior(Ystar,Xstar,n,m,p,Tstar,opts.ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,priorexo);
        % obtain posterior distribution parameters
        [Bcap,betacap,Scap,alphacap,phicap,alphatop]=bear.dopost(Xstar,Ystar,Tstar,k,n);
        % run Gibbs sampling for the dummy observation prior
        if favar.FAVAR==0
            [beta_gibbs,sigma_gibbs]=bear.dogibbs(opts.It,opts.Bu,Bcap,phicap,Scap,alphacap,alphatop,n,k);
            % compute posterior estimates
            [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.doestimates(betacap,phicap,Scap,alphacap,alphatop,n,k,cband);
        elseif favar.FAVAR==1
            [beta_gibbs,sigma_gibbs,favar,opts.It,opts.Bu]=bear.favar_dogibbs(opts.It,opts.Bu,Bhat,EPS,n,T,lags,data_endo,data_exo,const,favar,opts.ar,arvar,opts.lambda1,opts.lambda3,opts.lambda4,m,p,k,priorexo,Y,X,cband,Tstar);
            % median of the posterior estimates in this case
            [beta_median,B_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.favar_doestimates(favar);
        end


        % mean-adjusted BVAR model
    elseif opts.prior==61
        % set prior distribution parameters for the model
        [beta0, omega0, psi0, lambda0,r] = bear.maprior(opts.ar, arvar, opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,n,m,p,k1,q1,q2,opts.bex,blockexo,Fpconfint,Fpconfint2,chvar,regimeperiods,Dmatrix,equilibrium,data_endo,opts.priorf);
        % Create H matrix
        [TVEH, TVEHfuture]=bear.TVEcreateH(equilibrium,r,T,p,Fperiods);
        % check the priors
        bear.checkpriors(psi0,lambda0,TVEH,decimaldates1,data_endo,Dmatrix);
        q2=length(psi0);
        % run Gibbs sampler for estimation
        [beta_gibbs, sigma_gibbs, theta_gibbs, ss_record,indH,beta_theta_gibbs]=bear.TVEmagibbs(data_endo,opts.It,opts.Bu,beta0,omega0,psi0,lambda0,Y,X,n,T,k1,q1,p,regimeperiods,names,TVEH);
        %[beta_gibbs psi_gibbs sigma_gibbs delta_gibbs ss_record]=bear.magibbs(data_endo,data_exo,It,Bu,beta0,omega0,psi0,lambda0,Y,X,Z,n,m,T,k1,k3,q1,q2,q3,p);
        % compute posterior estimates
        [beta_median, beta_std, beta_lbound, beta_ubound, theta_median, theta_std, theta_lbound, theta_ubound, sigma_median]=bear.TVEmaestimates(beta_gibbs,theta_gibbs,sigma_gibbs,cband,q1,q2,n);
        %[beta_median beta_std beta_lbound beta_ubound psi_median psi_std psi_lbound psi_ubound sigma_median]=bear.maestimates(beta_gibbs,psi_gibbs,sigma_gibbs,cband,q1,q2,n);
    end

    % routines are different for IRFt 4, 5 & 6
    if IRFt==4
        if opts.prior~=61
            % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
            [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                =bear.irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,opts.It,opts.Bu);
        elseif opts.prior==61
            [struct_irf_record,D_record,gamma_record,hd_record,ETA_record,beta_gibbs,sigma_gibbs,favar]...
                =bear.irfres_prior(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,T,Y,X,signreslabels,FEVDresperiods,data_exo,HD,const,exo,strctident,pref,favar,IRFt,opts.It,opts.Bu,opts.prior);
        end
        if opts.prior~=61
            [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n);
        elseif opts.prior==61
            [beta_median, beta_std, beta_lbound, beta_ubound, theta_median, theta_std, theta_lbound, theta_ubound, sigma_median]=bear.TVEmaestimates(beta_gibbs,theta_gibbs,sigma_gibbs,cband,q1,q2,n);
        end
    elseif IRFt==5 % If IRFs have been set to an SVAR with IV identification (IRFt=5):
        [struct_irf_record,D_record,gamma_record,ETA_record,opts.It,opts.Bu,beta_gibbs,sigma_gibbs]=...
            bear.IRFt5_Bayesian(names,betahat,m,n,Xstar,Ystar,k,p,enddate,startdate,IRFperiods,IRFt,T,arvar,q, opts.It, opts.Bu,opts.lambda1, opts.lambda3,opts.lambda4,pref,strctident);
        [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
        % If IRFs have been set to an SVAR with IV identification & sign, rel. magnitude, FEVD, correlation restrictions (IRFt=6):
    elseif IRFt==6
        [struct_irf_record,D_record,gamma_record,ETA_record,beta_gibbs,sigma_gibbs, opts.It, opts.Bu]=...
            bear.IRFt6_Bayesian(betahat,IRFperiods,n,m,p,k,T,names,startdate,enddate,Xstar,FEVDresperiods,Ystar,pref,IRFt,arvar,q,opts.It,opts.Bu,opts.lambda1,opts.lambda3,opts.lambda4,strctident,favar);
        [beta_median,beta_std,beta_lbound,beta_ubound,sigma_median]=bear.IRFt456_estimates(beta_gibbs,sigma_gibbs,cband,q,n,k);
    end


    % FAVARs: we estimated the factors in data_endo (FY) It-Bu times, so compute a median estimate for X and Y
    if favar.FAVAR==1
        [X,Y,favar]=bear.favar_XYestimates(T,n,p,m,opts.It,opts.Bu,favar);
    end

    %% BLOCK 4: MODEL EVALUATION

    % compute the marginal likelihood for the model
    if opts.prior==11||opts.prior==12||opts.prior==13
        [logml,log10ml,ml]=bear.mmlik(Xstar,Xdum,ystar,ydum,n,Tstar,Tdum,q,sigma,beta0,omega0,betabar,opts.scoeff,opts.iobs);
    elseif opts.prior==21&&IRFt<=4 || opts.prior==22&&IRFt<=4
        [logml,log10ml,ml]=bear.nwmlik(Xstar,Xdum,Ydum,n,Tstar,Tdum,k,B0,phi0,S0,opts.alpha0,Sbar,alphabar,opts.scoeff,opts.iobs);
    elseif opts.prior==31||opts.prior==32
        [logml,log10ml,ml]=bear.inwmlik(Y,X,n,k,q,T,beta0,omega0,S0,opts.alpha0,beta_median,sigma_median,beta_gibbs,opts.It,opts.Bu,opts.scoeff,opts.iobs);
    elseif opts.prior==41||opts.prior==51||opts.prior==61||IRFt>4
        log10ml=nan;
    end

    %compute the DIC test
    if opts.prior==11||opts.prior==12||opts.prior==13||opts.prior==21||opts.prior==22|| opts.prior==31||opts.prior==32||opts.prior==41||opts.prior==51||opts.prior==61
        if IRFt<5
            [dic]=bear.dic_test(Y,X,n,beta_gibbs,sigma_gibbs,opts.It-opts.Bu,favar);
        else
            [dic]=0;
        end
    end

    if opts.prior~=61
        % merged the disp files, but we need some to provide some extra variables in the case we do not have prior 61
        theta_median=NaN; TVEH=NaN; indH=NaN;
    end
    % display the VAR results
    bear.bvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,log10ml,dic,X,Y,n,m,p,k,q,T,opts.prior,opts.bex,opts.hogs,opts.lrp,H,opts.ar,opts.lambda1,opts.lambda2,opts.lambda3,opts.lambda4,opts.lambda5,opts.lambda6,opts.lambda7,opts.lambda8,IRFt,const,beta_gibbs,endo,data_endo,exo,startdate,enddate,decimaldates1,stringdates1,pref,opts.scoeff,opts.iobs,opts.PriorExcel,strctident,favar,theta_median,TVEH,indH);

    % compute and display the steady state results
    if opts.prior~=61 %we have a ss_record output for the prior61
        [ss_record]=bear.ssgibbs(n,m,p,k,X,beta_gibbs,opts.It,opts.Bu,favar);
    end
    [ss_estimates]=bear.ssestimates(ss_record,n,T,cband);
    % display steady state
    bear.ssdisp(Y,n,endo,stringdates1,decimaldates1,ss_estimates,pref);


    %% BLOCK 5: IRFs
    % compute IRFs, HD and structural shocks
    if opts.prior==61 %%%for the mean adjusted model set m to zero
        m=0;
    end

    % run the Gibbs sampler to obtain posterior draws
    if IRFt==1 || IRFt==2 || IRFt==3
        [irf_record]=bear.irf(beta_gibbs,opts.It,opts.Bu,IRFperiods,n,m,p,k);
    end

    % If IRFs have been set to an unrestricted VAR (IRFt=1):
    if IRFt==1
        % run a pseudo Gibbs sampler to obtain records for D and gamma (for the trivial SVAR)
        [D_record, gamma_record]=bear.irfunres(n,opts.It,opts.Bu,sigma_gibbs);
        struct_irf_record=irf_record;
        % If IRFs have been set to an SVAR with Cholesky identification (IRFt=2):
    elseif IRFt==2
        % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
        [struct_irf_record, D_record, gamma_record,favar]=bear.irfchol(sigma_gibbs,irf_record,opts.It,opts.Bu,IRFperiods,n,favar);
        % If IRFs have been set to an SVAR with triangular factorisation (IRFt=3):
    elseif IRFt==3
        % run the Gibbs sampler to transform unrestricted draws into orthogonalised draws
        [struct_irf_record,D_record,gamma_record,favar]=bear.irftrig(sigma_gibbs,irf_record,opts.It,opts.Bu,IRFperiods,n,favar);
    end

    % If an SVAR was selected, also compute and display the structural shock series
    if IRFt==2||IRFt==3
        %%%%% I think we can merge both strshocks files
        if opts.prior~=61
            % compute first the empirical posterior distribution of the structural shocks
            [strshocks_record]=bear.strshocks(beta_gibbs,D_record,Y,X,n,k,opts.It,opts.Bu,favar);
        elseif opts.prior==61
            % compute first the empirical posterior distribution of the structural shocks
            [strshocks_record]=bear.TVEmastrshocks(beta_gibbs,theta_gibbs,D_record,n,k1,opts.It,opts.Bu,TVEH,indH,data_endo,p);
        end
        % compute posterior estimates
        [strshocks_estimates]=bear.strsestimates(strshocks_record,n,T,IRFband);
    elseif IRFt==4||IRFt==6||IRFt==5
        % compute posterior estimates
        [strshocks_estimates]=bear.strsestimates_set_identified(ETA_record,n,T,IRFband,struct_irf_record,IRFperiods,strctident);
    end
    % display the results
    if IRFt~=1
        bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
    end

    if IRF==1 || favar.IRFplot==1
        % compute posterior estimates
        if IRFt==1 || IRFt==2 || IRFt==3
            [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates(struct_irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record,favar);
        elseif IRFt==4||IRFt==5||IRFt==6
            [irf_estimates,D_estimates,gamma_estimates,favar]=bear.irfestimates_set_identified(struct_irf_record,n,IRFperiods,IRFband,D_record,strctident,favar);
        end

        if IRF==1
            % display the results
            bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
        end
        %display IRFs for information variables, output in excel
        if favar.IRFplot==1
            [favar]=bear.favar_irfdisp(favar,IRFperiods,endo,IRFt,strctident,pref);
        end
    end

    % estimate IRFs for exogenous variables
    if isempty(data_exo)~=1 %%%%%&& m>0
        [~,exo_irf_estimates]=bear.irfexo(beta_gibbs,opts.It,opts.Bu,IRFperiods,IRFband,n,m,p,k);
        % estimate IRFs for exogenous variables
        bear.irfexodisp(n,m,endo,exo,IRFperiods,exo_irf_estimates,pref);
    end


    %% BLOCK 6: FORECASTS

    % compute forecasts if the option has been retained
    if F==1
        % run the Gibbs sampler to obtain draws form the posterior predictive distribution
        %%%%% I think we can merge both forecast files
        if opts.prior~=61
            [forecast_record]=bear.forecast(data_endo_a,data_exo_p,opts.It,opts.Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const,Fstartlocation,favar);
        elseif opts.prior==61
            [forecast_record]=bear.TVEmaforecast(data_endo_a,data_exo_a,data_exo_p,opts.It,opts.Bu,beta_gibbs,sigma_gibbs,Fperiods,n,m,p,k1,k3,theta_gibbs,TVEHfuture,ss_record,indH);   %[forecast_record]=maforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,delta_gibbs,Fperiods,n,m,p,k1,k3);
        end

        % compute posterior estimates
        [forecast_estimates]=bear.festimates(forecast_record,n,Fperiods,Fband);
        % display the results for the forecasts
        bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
        % finally, compute forecast evaluation if the option was selected
        if Feval==1
            %OLS single variable with BIC lag selection VAR for Rossi test
            [OLS_Bhat, OLS_betahat, OLS_sigmahat, OLS_forecast_estimates, biclag]=bear.arbicloop(data_endo,data_endo_a,const,p,n,m,Fperiods,Fband);
            %%%%% I think we can merge both forecast files
            if opts.prior~=61
                [Forecasteval]=bear.bvarfeval(data_endo_c,data_endo_c_lags,data_exo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,p,k,opts.It,opts.Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref);
            elseif opts.prior==61
                [Forecasteval]=bear.TVEmafeval(data_endo_a,data_endo_c,data_endo_c_lags,data_exo_c,data_exo_c_lags,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,const,n,m,p,k1,k3,opts.It,opts.Bu,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,names,endo,pref,theta_gibbs,TVEHfuture,ss_record,indH);
            end
        end
    end


    %% BLOCK 7: FEVD

    % compute FEVD if the option has been retained
    if FEVD==1 || favar.FEVDplot==1
        % warning if the model is not fully identified as the results can be misleading
        if (IRFt==4 && size(strctident.signreslabels_shocks,1)~=n) || (IRFt==6 && size(strctident.signreslabels_shocks,1)~=n) || IRFt==5
            message='Model is not fully identified. FEVD results can be misleading.';
            msgbox(message,'FEVD warning','warn','warning');
        end

        % run the Gibbs sampler to compute posterior draws
        [fevd_estimates]=bear.fevd(struct_irf_record,gamma_record,opts.It,opts.Bu,n,IRFperiods,FEVDband);
        % compute approximate favar fevd estimates
        if favar.FEVDplot==1
            [favar]=bear.favar_fevd(gamma_record,opts.It,opts.Bu,n,IRFperiods,FEVDband,favar,IRFt,strctident);
        end
        % display the results
        bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
    end



    %% BLOCK 8: historical decomposition
    % compute historical decomposition if the option has been retained
    if HD==1 || favar.HDplot==1
        if opts.prior==61 % again, special case
            [strshocks_record]=bear.TVEmastrshocks(beta_gibbs,theta_gibbs,D_record,n,k1,opts.It,opts.Bu,TVEH,indH,data_endo,p);
            % run the Gibbs sampler to compute posterior draws
            [hd_record]=bear.TVEmahdecomp(beta_gibbs,D_record,strshocks_record,opts.It,opts.Bu,Y,n,p,k1,T); %ETA_record
            % compute posterior estimates
            [hd_estimates]=bear.hdestimates(hd_record,n,T,HDband);
            % display the results
            bear.hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels);

        else

            % run the Gibbs sampler to compute posterior draws
            [hd_record,favar]=bear.hdecomp_inc_exo(beta_gibbs,D_record,opts.It,opts.Bu,Y,X,n,m,p,k,T,data_exo,exo,endo,const,IRFt,strctident,favar);
            % compute posterior estimates
            if IRFt==1||IRFt==2||IRFt==3||IRFt==5
                [hd_estimates,favar]=bear.hdestimates_inc_exo(hd_record,n,T,HDband,favar); % output is here named hd_record fit the naming conventions of HDestdisp
            elseif IRFt==4||IRFt==6
                [hd_estimates,favar]=bear.hdestimates_set_identified(hd_record,n,T,HDband,IRFband,struct_irf_record,IRFperiods,strctident,favar);
            end
            % display the HDs
            bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
            %[favar]=HDdisp(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
        end
    end



    %% BLOCK 9: conditional forecasts

    % compute conditional forecasts if the option has been retained
    if CF==1
        % if the type of conditional forecasts corresponds to the standard methodology
        if CFt==1||CFt==2
            %%%%% I think both cforecast files can be merged
            if opts.prior~=61
                % run the Gibbs sampler to obtain draws from the posterior predictive distribution of conditional forecasts
                [cforecast_record,CFstrshocks_record]=bear.cforecast(data_endo_a,data_exo_a,data_exo_p,opts.It,opts.Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q);
            elseif opts.prior==61
                [cforecast_record]=bear.TVEmacforecast(data_endo_a,data_exo_a,data_exo_p,opts.It,opts.Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,n,m,p,k1,k3,beta_gibbs,D_record,gamma_record,theta_gibbs,TVEHfuture,ss_record,indH);
            end
            % if the type of conditional forecasts corresponds to the tilting methodology
        elseif CFt==3||CFt==4
            [cforecast_record]=bear.tcforecast(forecast_record,Fperiods,cfconds,cfintervals,CFt,n,Fband,opts.It,opts.Bu);
        end

        % compute posterior estimates
        [cforecast_estimates]=bear.festimates(cforecast_record,n,Fperiods,Fband);
        %[CFstrshocks_estimates]=bear.strsestimates(CFstrshocks_record,n,Fperiods,Fband); % structural shocks of the conditional forecast

        % display the results for the forecasts
        bear.cfdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,cforecast_estimates,pref);
    end

    % option to save matlab workspace
    if pref.workspace==1
        if numt>1
            save(fullfile(pref.results_path, [ pref.results_sub Fstartdate '.mat'] )); % Save Workspace
        end
    end

    Fstartdate_rolling=[Fstartdate_rolling; Fstartdate];

    % here finishes grand loop 2
    % if the model selected is not a BVAR, this part will not be run
end




