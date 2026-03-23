
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Grand loop 1: OLS VAR model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if the selected model is an OLS/maximum likelihood  VAR, run this part
if VARtype==1

    % model estimation
    [Bhat, betahat, sigmahat, X, Xbar, Y, y, EPS, eps, n, m, p, T, k, q]=bear.olsvar(data_endo,data_exo,const,lags);
    % compute interval estimates
    [beta_median, beta_std, beta_lbound, beta_ubound, sigma_median]=bear.olsestimates(betahat,sigmahat,X,k,q,cband);
    % display the VAR results
    bear.olsvardisp(beta_median,beta_std,beta_lbound,beta_ubound,sigma_median,X,Y,n,m,p,k,q,T,IRFt,const,endo,exo,startdate,enddate,stringdates1,decimaldates1,pref,favar,strctident);
    % compute and display the steady state results
    bear.olsss(Y,X,n,m,p,Bhat,stringdates1,decimaldates1,endo,pref);

    % IRFt routines
    if IRFt==1||IRFt==2||IRFt==3
        [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]...
            =bear.olsirft123(betahat,sigmahat,IRFperiods,IRFt,Y,X,n,m,p,k,q,IRFband,IRF,favar);
    elseif IRFt==4 % set identified, %%%% adjust beta sigma hat estimates
        [irf_estimates,D_record,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_record,favar]...
            =bear.olsirft4(betahat,sigmahat,IRFperiods,Y,X,n,m,p,k,pref,IRFband,T,FEVDresperiods,strctident,favar,IRFt);
    elseif IRFt==5 %point identified %%%% adjust beta sigma hat estimates
        [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]...
            =bear.olsirft5(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,strctident,IRFt,IRF,favar);
    elseif IRFt==6 %combination of 4 and 5, nothing more %%%% adjust beta sigma hat estimates
        [irf_estimates,D_record,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_record,favar]...
            =bear.olsirft6(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,FEVDresperiods,favar,strctident,IRFt);
    end

    % Structual shocks
    if IRFt==2||IRFt==3||IRFt==5
        bear.strsdispols(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
    elseif IRFt==4||IRFt==6
        bear.strsdisp(decimaldates1,stringdates1,strshocks_estimates,endo,pref,IRFt,strctident);
    end

    % IRFs (if activated)
    if IRF==1
        % display IRFs
        bear.irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,strctident);
    end

    %compute IRFs for information variables, output in excel
    if favar.IRFplot==1
        [favar]=bear.favar_irfols(irf_estimates,favar,const,Bhat,data_exo,n,m,k,lags,EPS,T,data_endo,IRFperiods,endo,IRFt,IRFband,strctident,pref);
    end


    % forecasts (if activated)
    if F==1
        [forecast_estimates]=bear.olsforecast(data_endo_a,data_exo_p,Fperiods,betahat,Bhat,sigmahat,n,m,p,k,const,Fband);
        bear.fdisp(Y,n,T,endo,stringdates2,decimaldates2,Fstartlocation,Fendlocation,forecast_estimates,pref);
        % forecast evaluation (if activated)
        if Feval==1
            bear.olsfeval(data_endo_c,stringdates3,Fstartdate,Fcenddate,Fcperiods,Fcomp,n,forecast_estimates,names,endo,pref);
        end
    end


    % FEVD (if activated)
    if FEVD==1 || favar.FEVDplot==1
        if IRFt==4&&size(strctident.signreslabels_shocks,1)~=n || IRFt==6&&size(strctident.signreslabels_shocks,1)~=n
            message='Model is not fully identified. FEVD results can be misleading.';
            msgbox(message,'FEVD warning','warn','warning');
        end
        % compute fevd estimates
        [fevd_estimates]=bear.olsfevd(irf_estimates,IRFperiods,gamma,n);
        %compute approximate favar fevd estimates
        if favar.FEVDplot==1
            [favar]=bear.favar_olsfevd(IRFperiods,gamma,favar,n,IRFt,strctident);
        end
        % display the results
        bear.fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,strctident,FEVD,favar);
    end

    % historical decomposition (if activated)
    if HD==1 || favar.HDplot==1
        % compute hd_record
        if IRFt==1||IRFt==2||IRFt==3||IRFt==5
            % compute hd_record, here we have the "true" values already
            [hd_estimates]=bear.hd_new_for_signres(const,exo,betahat,k,n,p,D,m,T,X,Y,IRFt,[]);
        elseif IRFt==4||IRFt==6
            % compute hd_record
            [hd_record]=bear.hdecompols(const,exo,k,n,p,m,T,X,Y,data_exo,IRFt,beta_record,D_record,1001,0,endo,strctident);
            % and compute the point estimates
            [hd_estimates]=bear.HDestimatesols(hd_record,n,T,HDband,strctident);
        end

        % FAVAR: scale hd_estimates with loadings
        if favar.FAVAR==1
            if favar.HDplot==1 && favar.pX==1
                [favar,favar.HD.hd_estimates]=bear.favar_hdestimates(favar,hd_estimates,n,IRFt,endo,strctident,favar.L(favar.plotX_index,:));
            end
        end
        % finally display
        bear.hddisp_new(hd_estimates,const,exo,n,m,Y,T,IRFt,pref,decimaldates1,stringdates1,endo,HDall,lags,HD,strctident,favar);
    end

    % here finishes grand loop 1
    % if the model selected is not an OLS VAR, this part will not be run
end
