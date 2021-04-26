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
      hd_estimates{jj,ii}(1,kk)=quantile(hd_record{jj,ii}(:,kk),(1-HDband)/2);
      %mean value
      hd_estimates{jj,ii}(2,kk)=quantile(hd_record{jj,ii}(:,kk),0.5);
      % upper bound
      hd_estimates{jj,ii}(3,kk)=quantile(hd_record{jj,ii}(:,kk),HDband+(1-HDband)/2);
      end
   end
end

for yy=1:3
%%recalculate the unexplaned part for the upper, lower, and median
HDsum = zeros(T,n); 
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T);
 for kk=1:T %loop over periods
     sumperiod=0; 
  for ii=1:contributors %loop over contributors (rows)
      sumperiod = sumperiod+hd_estimates{ii,jj}(yy,kk);
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 HDsum(:,jj)=sumvariable(1,:); 
 end
 
 %redetermine the unexplained part because we didnt choose the median
 %model, the pointwise median doesnt need to add up to the data

 unexplained = Y-HDsum(1:end,:); %%%%% do we take the median, upper, lower bound for Y here in the case of favar.FAVAR==1 && favar.onestep==1 ?
for jj=1:n
    hd_estimates{contributors+1,jj}(yy,:)=unexplained(:,jj)';
end
end

%% finally substract the sum of the contribution of the exogenous, constant,initial conditions from Y to get the
%part that was left to be explained by the shocks (for plotting reasons)
 Exosum = zeros(T,n); %
 for jj=1:n %loop over variables (columns)
 sumvariable = zeros(1,T);
 for kk=1:T %loop over periods
     sumperiod=0; 
  for ii=n+1:contributors %loop over contributors (rows)
      sumperiod = sumperiod+hd_estimates{ii,jj}(2,kk); 
  end
  sumvariable(1,kk) = sumperiod; 
 end 
 Exosum(:,jj)=sumvariable(1,:); 
 end 
 
 %% determine the part that was left to be explained by the shocks
%  aux = zeros(1,n);
 tobeexplained = Y - Exosum(1:end,:); 
%  tobeexplained = [aux; tobeexplained];
for jj=1:n
    hd_estimates{contributors+2,jj}(2,:)=tobeexplained(:,jj)';
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

% rearrange
hd_estimates_full = hd_estimates; %rename the estimates that include the lower and upper bound for plotting purposes
    clear hd_estimates; %clear the old version
    hd_estimates = cell(contributors+2,n); %create a new one that only contains the median
    for ii=1:n
        for jj=1:length(hd_estimates_full)
            hd_estimates{jj,ii}(1,:)=hd_estimates_full{jj,ii}(2,:); 
        end
    end