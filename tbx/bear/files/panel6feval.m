function [RMSE MAE MAPE Ustat CRPS_estimates]=panel6feval(N,n,forecast_record,forecast_estimates,Fcperiods,data_endo_c)














% preliminary task: obtain a matrix of forecasts over the common periods
for ii=1:N*n
forecast_c(:,ii)=forecast_estimates{ii,1}(2,1:Fcperiods)';
end
% then compute the matrix of forecast errors
ferrors=data_endo_c-forecast_c;



% compute first the sequential RMSE, from (1.8.11)

% square the forecast error matrix entrywise
sferrors=ferrors.^2;
% sum entries sequentially
sumsferrors=sferrors(1,:);
for ii=2:Fcperiods
sumsferrors(ii,:)=sumsferrors(ii-1,:)+sferrors(ii,:);
end
% divide by the number of forecast periods and take square roots to obtain RMSE
for ii=1:Fcperiods
RMSE(ii,:)=((1/ii)*sumsferrors(ii,:)).^0.5;
end



% compute then the sequential MAE, from (1.8.12)

% take the absolute value of the forecast error matrix
absferrors=abs(ferrors);
% sum entries sequentially
sumabsferrors=absferrors(1,:);
for ii=2:Fcperiods
sumabsferrors(ii,:)=sumabsferrors(ii-1,:)+absferrors(ii,:);
end
% divide by the number of forecast periods to obtain MAE
for ii=1:Fcperiods
MAE(ii,:)=(1/ii)*sumabsferrors(ii,:);
end



% compute the sequential MAPE, from (1.8.13)

% divide entrywise by actual values and take absolute values
absratioferrors=abs(ferrors./data_endo_c);
% sum entries sequentially
sumabsratioferrors=absratioferrors(1,:);
for ii=2:Fcperiods
sumabsratioferrors(ii,:)=sumabsratioferrors(ii-1,:)+absratioferrors(ii,:);
end
% divide by 100*(number of forecast periods) to obtain MAPE
for ii=1:Fcperiods
MAPE(ii,:)=(100/ii)*sumabsratioferrors(ii,:);
end



% compute the Theil's inequality coefficient, from (1.8.14)

% first compute the left term of the denominator
% square entrywise the matrix of actual data
sendo=data_endo_c.^2;
% sum entries sequentially
sumsendo=sendo(1,:);
for ii=2:Fcperiods
sumsendo(ii,:)=sumsendo(ii-1,:)+sendo(ii,:);
end
% divide by the number of forecast periods and take square roots
for ii=1:Fcperiods
leftterm(ii,:)=((1/ii)*sumsendo(ii,:)).^0.5;
end
% then compute the right term of the denominator
% square entrywise the matrix of forecast values
sforecasts=forecast_c.^2;
% sum entries sequentially
sumsforecasts=sforecasts(1,:);
for ii=2:Fcperiods
sumsforecasts(ii,:)=sumsforecasts(ii-1,:)+sforecasts(ii,:);
end
% divide by the number of forecast periods and take square roots
for ii=1:Fcperiods
rightterm(ii,:)=((1/ii)*sumsforecasts(ii,:)).^0.5;
end
% finally, compute the U stats
Ustat=RMSE./(leftterm+rightterm);



% now compute the continuous ranked probability score
   
% create the cell storing the results
CRPS=cell(n,1);
% loop over endogenous variables
for ii=1:N*n
   % loop over forecast periods on which actual data is known
   for jj=1:Fcperiods    
   % compute the continuous ranked probability score
   score=crps(forecast_record{ii,1}(:,jj),forecast_estimates{ii,1}(2,jj));
   CRPS{ii,1}(1,jj)=score;
   end
end
CRPS_estimates=(cell2mat(CRPS))';


