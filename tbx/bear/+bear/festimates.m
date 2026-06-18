function [forecast_estimates]=festimates(forecast_record,n,Fperiods,Fband)



% function [forecast_estimates]=festimates(forecast_record,n,Fperiods,Fband)
% calculates the point estimate (median), lower bound and upper bound of the forecast from the posterior distribution
% inputs:  - cell 'forecast_record': record of the gibbs sampler draws for the unconditional forecasts
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'Fperiods': number of forecast periods
%          - scalar 'Fband': confidence level for forecasts
% outputs: - cell 'forecast_estimates': lower bound, point estimates, and upper bound for the unconditional forecasts



% create first the cell that will contain the estimates
forecast_estimates=cell(n,1);

% for each variable and each forecast period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider forecast periods in turn
   for jj=1:Fperiods
   % compute first the lower bound
   forecast_estimates{ii,1}(1,jj)=quantile(forecast_record{ii,1}(:,jj),(1-Fband)/2);
   % then compute the median
   forecast_estimates{ii,1}(2,jj)=quantile(forecast_record{ii,1}(:,jj),0.5);
   % finally compute the upper bound
   forecast_estimates{ii,1}(3,jj)=quantile(forecast_record{ii,1}(:,jj),(1-(1-Fband)/2));
   end
end















