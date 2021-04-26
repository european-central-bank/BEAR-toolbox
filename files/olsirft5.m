function [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]...
    =olsirft5(betahat,IRFperiods,Y,X,n,m,p,k,endo,pref,IRFband,names,enddate,startdate,T,data_endo,data_exo,const,strctident,IRFt,IRF,favar)

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


It=1001;
Bu=0;
Acc=It-Bu;

%% IV routine
[~,~,~,~,~,irf_storage,storage2]=...
    irfIVols(betahat,n,m,p,k,T,names,startdate,enddate,X,Y,endo,data_endo,data_exo,const,pref,strctident,IRFt,IRFperiods,It,Bu);


%% reorganise storage
% loop over iterations
for ii=1:Acc
    % loop over IRF periods
    for jj=1:IRFperiods
        % loop over variables
        for kk=1:n
            % loop over shocks
            for ll=1:n
                irf_record{kk,ll}(ii,jj)=irf_storage{ii,1}(kk,ll,jj);
            end
        end
    end
    D_record(:,ii)=storage2{ii,1}(:);
end

for ii=1:n^2
    D_estimates(ii,1)=quantile(D_record(ii,:),0.5);
end
D=reshape(D_estimates,n,n);
D_estimates=D(:);
gamma=eye(n); %equivalent to the gamma_record output of irfres
gamma_estimates=gamma(:);

% create then the cell storing the point estimates and confidence bands
irf_estimates=cell(n,n);

if IRF==1 | favar.IRF.plot==1
    % rearrange
    for ii=1:n
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                % median
                irf_estimates{jj,ii}(2,kk)=quantile(irf_record{jj,ii}(:,kk),0.5);
                % lower bound
                irf_estimates{jj,ii}(1,kk)=quantile(irf_record{jj,ii}(:,kk),(1-IRFband)/2);
                % upper bound
                irf_estimates{jj,ii}(3,kk)=quantile(irf_record{jj,ii}(:,kk),IRFband+(1-IRFband)/2);
            end
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
% Compute first the model residuals
Bhat=reshape(betahat,k,n);
EPS=Y-X*Bhat;
% Then use (XXX) to recover the structural shocks
ETA=D\EPS';
% output
strshocks_estimates=ETA;

