function [irf_estimates,D,gamma,D_estimates,gamma_estimates,strshocks_estimates,favar]=olsirft123(betahat,sigmahat,IRFperiods,IRFt,Y,X,n,m,p,k,q,IRFband,IRF,favar)

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


% this function implements the procedure described p44-46

% recover omeagahat, the (OLS) variance-covariance matrix for betahat; use proposition 11.1, in Hamilton (p 298-299)
omegahat=kron(sigmahat,(X'*X)\speye(k));

% compute D, the structural matrix associated to sigma
if IRFt==1
    D=eye(n);
    gamma=sigmahat;
elseif IRFt==2
    D=chol(nspd(sigmahat),'lower');
    gamma=eye(n);
elseif IRFt==3
    [D,gamma]=triangf(sigmahat);
end
gamma_estimates=gamma(:);
D_estimates=D(:);
D=reshape(D_estimates,n,n);
% Compute first the model residuals
Bhat=reshape(betahat,k,n);
EPS=Y-X*Bhat;
% Then use (XXX) to recover the structural shocks
ETA=D\EPS';
% output
strshocks_estimates=ETA;

%% compute IRFs
% create then the cell storing the point estimates and confidence bands
irf_estimates=cell(n,n);
if IRF==1 | favar.IRF.plot==1
    % create the cell aray that will store the values from the simulations
    irf_record=cell(n,n);
    
    % obtain point estimates for orthogonalised IRFs
    [~,ortirfmatrix]=irfsim(betahat,D,n,m,p,k,IRFperiods);
    
    % save the results in the cell irf_estimates
    % deal with shocks in turn
    for ii=1:n
        % loop over variables
        for jj=1:n
            % loop over IRF periods
            for kk=1:IRFperiods
                irf_estimates{jj,ii}(2,kk)=ortirfmatrix(jj,ii,kk);
            end
        end
    end
    
    % start the Monte Carlo phase
    for ii=1:1000
        % draw a random vector beta from its distribution
        % if the produced VAR model is not stationary, draw another vector, and keep drawing till a stationary VAR is obtained
        beta=betahat+chol(nspd(omegahat),'lower')*randn(q,1);
        % % % [stationary,~]=checkstable(beta,n,p,k);
        % % %    while stationary==0
        % % %    beta=betahat+chol(nspd(omegahat),'lower')*randn(q,1);
        % % %    [stationary,~]=checkstable(beta,n,p,k);
        % % %    end
        
        % obtain orthogonalised IRFs from this beta vector
        [~,ortirfmatrix]=irfsim(beta,D,n,m,p,k,IRFperiods);
        
        % record the results in the cell irf_record
        % deal with shocks in turn
        for jj=1:n
            % loop over variables
            for kk=1:n
                % loop over IRF periods
                for ll=1:IRFperiods
                    irf_record{kk,jj}(ii,ll)=ortirfmatrix(kk,jj,ll);
                end
            end
        end
        
        % go for the next iteration
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
end

% check if the variables have been transformed
if favar.FAVAR==1
    if (IRF==1 | favar.IRF.plot==1) && (favar.transformation==1 || favar.plot_transform==1)
        % re-transform irf_estimates
        favar.IRF.irf_estimates_nottransformed=irf_estimates; % before, save untransformed IRFs
        % re-transform
        [irf_estimates]=favar_retransX_irf_estimates(irf_estimates,favar.transformationindex_endo,favar.levels);
    end
end