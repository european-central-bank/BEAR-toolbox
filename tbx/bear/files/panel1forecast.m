function [forecast_estimates]=panel1forecast(sigmahat,bhat,k,n,const,data_exo_p,Fperiods,N,data_endo_a,p,T,m,Fband)




















% obtain Bhat from bhat
Bhat=reshape(bhat,k,n);

% initiate the forecast_estimates cell
forecast_estimates={};

% generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
else
end


% because forecasts have to be produced for each unit, loop over units
for ii=1:N


% generate the point estimates
% recover the lagged endogenous required to produce the forecasts
temp=data_endo_a(end-p+1:end,:,ii);
% repeat the process for periods T+1 to T+h
for jj=1:Fperiods
% Define the matrix of regressors X by using lagX on temp; retain only the last row of the matrix
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X from the endogenous variables only
   if isempty(data_exo_p)
   X=lagx(temp,p-1);
   X=X(end,:);
   % if there are exogenous vaiables, concatenate them next to the endogenous
   else
   X=lagx(temp,p-1);
   X=[X(end,:) data_exo_p(jj,:)];
   end
% obtain predicted value for T+jj
yp=X*Bhat;
% concatenate the transpose of yp to the top of temp
temp=[temp;yp];
% repeat until values are obtained for T+h
end



% finally, generate the confidence bands
% this requires to estimate the forecast error matrix sigmaf for each forecast period
% to do so, it is first necessary to obtain irfs
[irfmatrix,~]=irfsim(bhat,eye(n),n,m,p,k,Fperiods);
% then initiate sigmaf for period 1
sigmaf=irfmatrix(:,:,1)*sigmahat*irfmatrix(:,:,1)';
% and increment for each forecast period
for jj=2:Fperiods
sigmaf(:,:,jj)=sigmaf(:,:,jj-1)+irfmatrix(:,:,jj)*sigmahat*irfmatrix(:,:,jj)';
end
% with the sigmaf series, it is possible to compute the confidence intervals
% first compute the percentile of the normal distribution corresponding to size of the confidence interval
c_low=norminv((1-Fband)/2,0,1);
c_high=norminv(Fband+(1-Fband)/2,0,1);




for jj=1:n
% record forecast, point estimate
forecast_estimates{jj,1,ii}(2,:)=temp(p+1:end,jj)';
   % then loop over forecast periods
   for kk=1:Fperiods
   % record forecast, lower bound
   forecast_estimates{jj,1,ii}(1,kk)=forecast_estimates{jj,1,ii}(2,kk)+c_low*sigmaf(jj,jj,kk)^0.5;
   % record forecast, upper bound
   forecast_estimates{jj,1,ii}(3,kk)=forecast_estimates{jj,1,ii}(2,kk)+c_high*sigmaf(jj,jj,kk)^0.5;
   end
end

end