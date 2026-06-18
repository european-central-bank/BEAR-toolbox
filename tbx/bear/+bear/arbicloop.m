function [OLS_Bhat, OLS_betahat, OLS_sigmahat, OLS_forecast_estimates, biclag]=arbicloop(data_endo,data_endo_a,const,p,n, m, Fperiods, Fband)

% function [OLS_Bhat{ii}, OLS_betahat{ii}, OLS_sigmahat{ii}, OLS_forecast_estimates]=arbicloop(data_endo,data_endo_a,const,p,n)
% computes individual OLS estimations of autoregressive models and record their residual variances, as stated p16 of technical guide
% inputs:  - matrix 'data_endo': matrix of endogenous data used for model estimation
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'Fperiods': number of forecast periods
%          - scalar 'Fband': confidence level for forecasts
% outputs: - cell 'OLS_Bhat' :
%          - cell 'OLS_betahat' :
%          - cell 'OLS_sigmahat': residual variance of individual AR models estimated for each endogenous variable
%          - cell 'OLS_forecast_estimates :


bic=[];
nvar=1;
%loop over lags(p)
for ii=1:p
  [sigmahatlag]=bear.arloop(data_endo,const,ii,n);
   bic=[bic -2*log(sigmahatlag)+(log(length(data_endo))*nvar)];
end

%optimising VAR for AR - for each one.
[bicmin, biclag]=min(bic', [], 1);

% Estimating and forecasting for BIC optimised model
% loop over columns of data_endo
for ii=1:n
% Estimating BIC optimised VAR and record parameters and residual variance
[OLS_Bhat{ii}, OLS_betahat{ii}, OLS_sigmahat{ii},~,~,~,~,~,~,~,~,~,~,~,~]=bear.olsvar(data_endo(:,ii),[],const,biclag(ii));
% Forecasting for BIC optimised model
[OLS_forecast_estimates{ii}]=bear.olsforecast(data_endo_a(:,ii),[],Fperiods,OLS_betahat{ii},OLS_Bhat{ii},OLS_sigmahat{ii},1,m,biclag(ii),biclag(ii)+1,const,Fband);
end




