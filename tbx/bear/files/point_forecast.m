%% Point Forecast Evaluation

% Number of Observations in Forecasted Sample
T = size(actualdata,2); 

% Create Vector of Dates for Plotting
startdate = char(date_vec(end-numt+1,:));
enddate   = char(date_vec(end,:));
[pdate,stringdate] = genpdate(names,0,frequency,startdate,enddate);

% Rossi-Sekhposyan (JAE,2016) Fluctuation Rationality Test
RS_PF; 
