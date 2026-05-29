function [fevd_estimates]=fevdestimates(fevd_record,n,IRFperiods,FEVDband)



% function [fevd_estimates]=fevdestimates(fevd_record,n,IRFperiods,FEVDband)
% calculates the point estimate (median), lower bound and upper bound of the FEVD from the posterior distribution
% inputs:  - cell 'forecast_record': record of the gibbs sampler draws for the unconditional forecasts
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - scalar 'FEVDband': confidence level for FEVD
% outputs: - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD



% create first the cell that will contain the estimates
fevd_estimates=cell(n,n);

% for each variable and each variable contribution along with each period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider contributions in turn
   for jj=1:n
      % consider periods in turn
      for kk=1:IRFperiods
      % compute first the lower bound
      fevd_estimates{ii,jj}(1,kk)=quantile(fevd_record{ii,jj}(:,kk),(1-FEVDband)/2);
      % then compute the median
      fevd_estimates{ii,jj}(2,kk)=quantile(fevd_record{ii,jj}(:,kk),0.5);
      % finally compute the upper bound
      fevd_estimates{ii,jj}(3,kk)=quantile(fevd_record{ii,jj}(:,kk),1-(1-FEVDband)/2);
      end
   end
end















