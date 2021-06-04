function [irf_estimates,D_record,gamma,D_estimates,gamma_estimates,strshocks_estimates,medianmodel,beta_record,favar]=...
    olsirft4(betahat,sigmahat,IRFperiods,Y,X,n,m,p,k,pref,IRFband,T,FEVDresperiods,strctident,favar,IRFt)


% function [irf_estimates,D,gamma,D_estimates,gamma_estimates]=bear.olsirf(betahat,sigmahat,IRFperiods,IRFt,X,n,m,p,k,q,sims,IRFband)
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


%% draw from VAR posterior
%sample beta and sigma from the VAR distribution centered around the OLS estimate
inv_sigma_hat = inv(bear.nspd(sigmahat)); %invert sigmahat as it is frequently used afterwards
It=1001; %%number of minimum draws accepted
Bu=0;
Acc=It-Bu;
beta_gibbs = nan(k*n,Acc);
sigma_gibbs=nan(n^2,Acc);
% Draw Sigma from inverse wishart and beta from multivariate normal around OLS estimates (equivalent to Normal wishart )
for ii=1:Acc
    inv_sigma_draw = wishrnd(inv_sigma_hat/T,T); % T-k here!? because we define sigmahat 1/T-k *... We use sigmahat with df correction in diffuse gibbs sampler
    sigma_draw     = inv(inv_sigma_draw);
    % Draw beta from a multivariate normal given the draw for sigma,
    aux1 = inv(X'*X);
    aux2 = kron(sigma_draw,aux1);
    betadraw = mvnrnd(betahat,aux2);
    %[stationary]=bear.checkstable(betadraw,n,p,k); %only retain stationary draws
    %    while stationary==0
    %    betadraw = mvnrnd(betahat,aux2);
    %    [stationary]=bear.checkstable(betadraw,n,p,k);
    %    end
    %B=reshape(beta,size(B));
    beta_gibbs(:,ii)=betadraw;
    sigma_gibbs(:,ii)=bear.vec(sigma_draw);
end

%% now, check the restrictions
[irf_record,D_record,~,ETA_record,beta_record]...
    =bear.irfres(beta_gibbs,sigma_gibbs,[],[],IRFperiods,n,m,p,k,Y,X,FEVDresperiods,strctident,pref,favar,IRFt,It,Bu);
% create then the cell storing the point estimates and confidence bands
irf_estimates=cell(n,n);

% re-transform irf_record
if favar.FAVAR==1
    %check if the variables have been transformed
    if favar.transformation==1 || favar.plot_transform==1
        favar.IRF.irf_record_nottransformed=irf_record; % before, save untransformed IRFs
        [irf_record]=bear.favar_retransX_irf_record(irf_record,favar.transformationindex_endo,favar.levels);
    end
end

%% save the median/OLS results
if strctident.MM==0
    % D and gamma if we dont go for medianmodel
    for ii=1:n^2
        D_estimates(ii,1)=quantile(D_record(ii,:),0.5);
        %gamma(ii,1)=quantile(gamma_record(ii,:),0.5);
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
    medianmodel=NaN; % no medianmodel
    
elseif strctident.MM==1 % if median model has been chosen
    [medianmodel,~,~]=bear.find_medianmodel(n,irf_record,IRFperiods,IRFband);
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
end

% then compute the confidence interval from the bootstrap values
for ii=1:n % deal with shocks in turn
    for jj=1:n % loop over variables
        for kk=1:IRFperiods % loop over time periods
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
        [irf_estimates]=bear.favar_retransX_irf_estimates(irf_estimates,favar.transformationindex_endo,favar.levels);
    end
end

%% finally, estimate structural shocks
[strshocks_estimates]=bear.strsestimates_set_identified(ETA_record,n,T,IRFband,irf_record,IRFperiods,strctident);

