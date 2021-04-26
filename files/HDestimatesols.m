function [hd_estimates]=HDestimatesols(hd_record,n,T,HDband,strctident)



% function [hd_estimates]=hdestimates(hd_record,n,T,HDband)
% calculates the point estimate (median), lower bound and upper bound of the historical decomposition from the posterior distribution
% inputs:  - cell 'hd_record': record of the gibbs sampler draws for the historical decomposition
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - scalar 'HDband': confidence level for forecasts
% outputs: - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition



% create first the cell that will contain the estimates
hd_estimates=cell(length(hd_record),n);

if strctident.MM==0
% deal with shocks in turn
for ii=1:n
   % loop over variables
   for jj=1:length(hd_record)
      % loop over time periods
      for kk=1:T
      % consider the higher and lower confidence band for the hd
      % lower bound
      hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(2,kk),(1-HDband)/2);
      %mean value
      hd_estimates{jj,ii}(2,kk)=quantile(hd_record{jj,ii}(2,kk),0.5);
      % upper bound
      hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(2,kk),HDband+(1-HDband)/2);
      end
   end
end

elseif strctident.MM==1 %Median Model
for ii=1:n
   % loop over variables
   for jj=1:length(hd_record)
      % loop over time periods
      for kk=1:T
      % consider the higher and lower confidence band for the hd
      % lower bound
      hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
      %medianmodel
      hd_estimates{jj,ii}(2,kk)= hd_record{jj,ii}(medianmodel,kk); %get the best performing model in terms of IRFs
      % upper bound
      hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),HDband+(1-HDband)/2);
      % upper bound
      end
   end
end
end