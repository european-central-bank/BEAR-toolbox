%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rolling forecast evaluation
% based on Francesca Loria
% This Version: February 2018
% Input:
% 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
%see later
%gr_pf_windowSize = 19;
%gr_pf_windowSize = round(evaluation_size*window_size);

% 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
%see later
%rs_pf_windowSize = 25; 
%rs_pf_windowSize = round(evaluation_size*window_size); 

% 3. See Section 7. for Additional User Input required for Density Forecast Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RMSE_rolling=[];
for i=1:numt

Fstartdate=char(Fstartdate_rolling(i,:));

   output = char(strcat([pref.datapath '\results\' pref.results_sub Fstartdate '.mat']));
   
% load forecasts
   load(output,'forecast_estimates','forecast_record','varendo','names','frequency', 'Forecasteval')
% load OLS AR forecast estimates as benchmark
   load(output,'OLS_forecast_estimates', 'OLS_Bhat', 'OLS_betahat', 'OLS_sigmahat', 'biclag')

   
    for j = 1:length(forecast_estimates)
        ols_forecasts(j,i)    = OLS_forecast_estimates{1,j}{1,1}(2,hstep); % assign median
        forecasts(j,i)        = forecast_estimates{j}(2,hstep); % assign median
        forecasts_dist(:,j,i) = sort(forecast_record{j,1}(:,1));     % assign entire distribution
    end
    sample=['f' Fstartdate];
    RMSE_rolling = [RMSE_rolling; Forecasteval.RMSE];
    Rolling.RMSE.(sample)=Forecasteval.RMSE;
    Rolling.MAE.(sample)=Forecasteval.MAE;
    Rolling.MAPE.(sample)=Forecasteval.MAPE;
    Rolling.Ustat.(sample)=Forecasteval.Ustat;
    Rolling.CRPS_estimates.(sample)=Forecasteval.CRPS_estimates;
    Rolling.S1_estimates.(sample)=Forecasteval.S1_estimates;
    Rolling.S2_estimates.(sample)=Forecasteval.S2_estimates;
end
  
%% Load Actual Data and Other Inputs
%load(['Results_',num2str(hstep),'H/results_' start{1} '.mat'],'data','frequency','Bu')
actualdata = data(end-numt+1:end,:)'; 

save('forecast_eval.mat','forecasts','actualdata');

%% 7. Forecast Evaluation

var_feval = endo;

% Block size for the Inoue (2001) bootstrap procedure, 
% default is P^(1/3), where P is the size of the out-of-sample portion of
% the available sample of size T+h
P = length(forecasts);
el = round(P^(1/3));

% 1. Window Size of the Giacomini-Rossi JAE(2010) Fluctuation Test
%gr_pf_windowSize = 19;
gr_pf_windowSize = round(evaluation_size*P);

% 2. Window Size of the Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
%rs_pf_windowSize = 25; 
%rs_pf_windowSize = round(evaluation_size*window_size); 
rs_pf_windowSize = round(evaluation_size*P); 


% 5. Number of bootstrap replications in the calculation of CV for the 
% Rossi-Sekhposyan test for multiple-step ahead forecast densities (h>1),
% default is 300
bootMC = 300;


for ind_feval=1:length(endo) %index of selected variable
ind_deval=ind_feval;

%Grid
    for ii=1:size(forecasts_dist(:,ind_feval(1),:),3)
        for jj=1:size(forecasts_dist(:,ind_feval(1),:),1)-1
            diff(jj) = squeeze(forecasts_dist(jj+1,ind_feval(1),ii) - forecasts_dist(jj,ind_feval(1),ii));
        end
        mdiff(ii) = mean(diff);
    end
    tdiff = max(mdiff);

gridDF = min(floor(min(forecasts_dist(:,ind_feval(1),:)))):tdiff:max(ceil(max(forecasts_dist(:,ind_feval(1),:))));

startdate = char(Fstartdate_rolling(1,:));
enddate   = char(Fstartdate_rolling(end,:));
[pdate,stringdate] = genpdate(names,0,frequency,startdate,enddate); 

    RS_PF; % Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
    RS_DF; % Rossi-Sekhposyan (2016) Tests for Correct Specification of Forecast Densities
    GR_PF; % Giacomini-Rossi JAE(2010) Fluctuation Test
    

end %loop ind_feval