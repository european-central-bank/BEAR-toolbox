function [forecast_record,forecast_estimates]=panel4forecast(N,n,p,k,data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,const,Fband,Fstartlocation,favar)








% initiate the cell recording the forecast draws
forecast_record={};
forecast_estimates={};

% because the forecasts have to be computed for each unit, loop over units
for ii=1:N
% run the Gibbs sampler for unit ii
forecast_record(:,:,ii)=forecast(data_endo_a(:,:,ii),data_exo_p,It,Bu,beta_gibbs(:,:,ii),sigma_gibbs(:,:,ii),Fperiods,n,p,k,const,Fstartlocation,favar);
% obtain point estimates and credibility intervals for unit ii
forecast_estimates(:,:,ii)=festimates(forecast_record(:,:,ii),n,Fperiods,Fband);
end































