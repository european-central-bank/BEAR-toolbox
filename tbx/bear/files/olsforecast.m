function [forecast_estimates]=olsforecast(data_endo_a,data_exo_p,Fperiods,betahat,Bhat,sigmahat,n,m,p,k,const,Fband)



% function [forecast_estimates]=olsforecast(data_endo_a,data_exo_p,Fperiods,betahat,Bhat,sigmahat,n,m,p,k,const,Fband)
% computes unconditional forecast values (point estimates and confidence bands) for the OLS VAR model
% inputs:  - matrix 'data_endo_a': matrix of pre-forecast endogenous data
%          - matrix 'data_exo_p': predicted values for the exogenous variables over the forecast periods
%          - integer 'Fperiods': number of forecast periods
%          - vector 'betahat': OLS VAR coefficients in vectorised form (defined in 1.1.15)
%          - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9)
%          - matrix 'sigmahat': OLS VAR variance-covariance matrix of residuals (defined in 1.1.10)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - scalar 'Fband': confidence level for forecasts
% outputs: - cell 'forecast_estimates': lower bound, point estimates, and upper bound for the unconditional forecasts 



% this function implements the chain rule of forecast, desibed p38 of the technical guide


% point estimates for forecasts are obtained using the chain rule for forecast in Lutkepohl (1991), equation (2.2.3) p 29
% approximate confidence interval are obtained from Lutkepohl (1991), formula (3.5.15) p 89, based on the sample mean squared error matrix (2.2.10)


% generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
else
end



% then generate the point estimates
% recover the lagged endogenous required to produce the forecasts
temp=data_endo_a(end-p+1:end,:);
% repeat the process for periods T+1 to T+h
for ii=1:Fperiods
% Define the matrix of regressors X by using lagX on temp; retain only the last row of the matrix
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X from the endogenous variables only
   if isempty(data_exo_p)
   X=lagx(temp,p-1);
   X=X(end,:);
   % if there are exogenous vaiables, concatenate them next to the endogenous
   else
   X=lagx(temp,p-1);
   X=[X(end,:) data_exo_p(ii,:)];
   end
% obtain predicted value for T+ii
yp=X*Bhat;
% concatenate the transpose of yp to the top of temp
temp=[temp;yp];
% repeat until values are obtained for T+h
end



% finally, generate the confidence bands
% this requires to estimate the forecast error matrix sigmaf for each forecast period
% to do so, it is first necessary to obtain irfs
[irfmatrix,~]=irfsim(betahat,eye(n),n,m,p,k,Fperiods);
% then initiate sigmaf for period 1
sigmaf(:,:,1)=irfmatrix(:,:,1)*sigmahat*irfmatrix(:,:,1)';
% and increment for each forecast period
for ii=2:Fperiods
sigmaf(:,:,ii)=sigmaf(:,:,ii-1)+irfmatrix(:,:,ii)*sigmahat*irfmatrix(:,:,ii)';
end
% with the sigmaf series, it is possible to compute the confidence intervals
% first compute the percentile of the normal distribution corresponding to size of the confidence interval
c_low=norminv((1-Fband)/2,0,1);
c_high=norminv(Fband+(1-Fband)/2,0,1);




% finally, create and fill the forecast_estimates cell
forecast_estimates=cell(n,1);
for ii=1:n
% record forecast, point estimate
forecast_estimates{ii,1}(2,:)=temp(p+1:end,ii)';
   % then loop over forecast periods
   for jj=1:Fperiods
   % record forecast, lower bound
   forecast_estimates{ii,1}(1,jj)=forecast_estimates{ii,1}(2,jj)+c_low*sigmaf(ii,ii,jj)^0.5;
   % record forecast, upper bound
   forecast_estimates{ii,1}(3,jj)=forecast_estimates{ii,1}(2,jj)+c_high*sigmaf(ii,ii,jj)^0.5;
   end
end

