function [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_gibbs,favar]=...
    olsirft6(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,FEVDresperiods,favar,strctident,IRFt)


% function [irf_estimates,D,gamma,D_estimates,gamma_estimates]=olsirf(betahat,sigmahat,IRFperiods,IRFt,X,n,m,p,k,q,sims,IRFband)
% computes IRF values (point estimates and confidence bands) for the OLS VAR model
% inputs:  - vector 'betahat': OLS VAR coefficients in vectorised form (defined in 1.1.15)
%          - matrix 'sigmahat': OLS VAR variance-covariance matrix of residuals (defined in 1.1.10)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - scalar 'IRFband': confidence level for IRFs
% outputs: - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs
%          - matrix 'D': structural matrix for the OLS model (defined in 2.3.3)
%          - matrix 'gamma': structural disturbance variance-covariance matrix (defined p 48 of technical guide)
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form

% 1000 draws should be enough here
It=1001;
Bu=0;

%% compute the IV part
[beta_draws,sigma_draws,IV_draws,C_draws,D1ols]...
    =irfIVols(betahat,n,m,p,k,T,names,startdate,enddate,X,Y,endo,data_endo,data_exo,const,pref,strctident,IRFt,IRFperiods,It,Bu);

%% check the restrictions
[irf_record,D_record,~,ETA_record,beta_gibbs]...
    =irfres(beta_draws,sigma_draws,C_draws,IV_draws,IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);


% save the median/OLS results in the cell irf_estimates
% create then the cell storing the point estimates and confidence bands
irf_estimates=cell(n,n);

% re-transform irf_record
if favar.FAVAR==1
    %check if the variables have been transformed
    if favar.transformation==1 || favar.plot_transform==1
        favar.IRF.irf_record_nottransformed=irf_record; % before, save untransformed IRFs
        [irf_record]=favar_retransX_irf_record(irf_record,favar.transformationindex_endo,favar.levels);
    end
end

% deal with shocks in turn
if strctident.MM==0
    %get the D matrix if we dont go for medianmodel
    for ii=1:n^2
        D_estimates(ii,1)=quantile(D_record(ii,:),0.5);
    end
    D=reshape(D_estimates,n,n);
    D_estimates=D(:);
    
    gamma=eye(n); %equivalent to the gamma_record output of irfres
    gamma_estimates=gamma(:);
    %now loop over IRFs
    for ii=1:n
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                irf_estimates{jj,ii}(2,kk)=quantile(irf_record{jj,ii}(:,kk),0.5);
            end
        end
    end
    medianmodel=0;
elseif strctident.MM==1 %if median model has been chosen
    [medianmodel,~,~]=find_medianmodel(n,irf_record,IRFperiods,IRFband);
    for ii=1:n
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                irf_estimates{jj,ii}(2,kk)=irf_record{jj,ii}(medianmodel,kk);
            end
        end
    end
    
    D=reshape(D_record(:,medianmodel),n,n);
    D_estimates=D(:);
    
    gamma=eye(n); %equivalent to the gamma_record output of irfres
    gamma_estimates=gamma(:);
end %end of IRFt loop


if strctident.TakeOLS==1
    %D_estimates(1:n)=D1ols;
    D=reshape(D1ols,n,n);
    D_estimates=D(:);
    % obtain point estimates for orthogonalised IRFs
    [~,ortirfmatrix]=irfsim(betahat,D(:,1),n,m,p,k,IRFperiods);
    for ii=1
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                irf_estimates{jj,ii}(2,kk)=ortirfmatrix(jj,ii,kk);
            end
        end
    end
end


% then compute the confidence interval from the bootstrap values
% deal with shocks in turn
for ii=1:n
    % loop over variables
    for jj=1:n
        % loop over time periods
        for kk=1:IRFperiods
            % consider the higher and lower confidence band for the response of variable jj to shock ii at forecast period kk from the bootstrap simulations
            % lower bound
            irf_estimates{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),(1-IRFband)/2);
            % upper bound
            irf_estimates{jj,ii}(3,kk)=quantile(irf_record{jj,ii}(:,kk),IRFband+(1-IRFband)/2);
        end
    end
end

% check if the variables have been transformed
if favar.FAVAR==1
    if favar.transformation==1 || favar.plot_transform==1
        % re-transform irf_estimates
        favar.IRF.irf_estimates_nottransformed=irf_estimates; % before, save untransformed IRFs
        % re-transform
        [irf_estimates]=favar_retransX_irf_estimates(irf_estimates,favar.transformationindex_endo,favar.levels);
    end
end

% finally, estimate structural shocks
[strshocks_estimates]=strsestimates_set_identified(ETA_record,n,T,IRFband,irf_record,IRFperiods,strctident);

