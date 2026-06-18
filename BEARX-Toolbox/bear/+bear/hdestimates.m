function [hd_estimates]=hdestimates(hd_record,n,T,HDband)



% function [hd_estimates]=hdestimates(hd_record,n,T,HDband)
% calculates the point estimate (median), lower bound and upper bound of the historical decomposition from the posterior distribution
% inputs:  - cell 'hd_record': record of the gibbs sampler draws for the historical decomposition
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - scalar 'HDband': confidence level for forecasts
% outputs: - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition



% create first the cell that will contain the estimates
hd_estimates=cell(n,n+1);

% for each variable, each shock and each forecast period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider shocks in turn
   for jj=1:n+1
      % consider sample periods in turn
      for kk=1:T
      % compute first the lower bound
      hd_estimates{ii,jj}(1,kk)=quantile(hd_record{ii,jj}(:,kk),(1-HDband)/2);
      % then compute the median
      hd_estimates{ii,jj}(2,kk)=quantile(hd_record{ii,jj}(:,kk),0.5); 
      % finally compute the upper bound
      hd_estimates{ii,jj}(3,kk)=quantile(hd_record{ii,jj}(:,kk),1-(1-HDband)/2);
      end
   end
end















