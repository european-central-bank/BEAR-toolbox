function [forecastmatrix]=forecastsim(data_endo_a,data_exo_p,beta,n,p,k,horizon)


% function [forecastmatrix]=forecastsim(data_endo_a,data_exo_p,beta,n,p,k,horizon)
% computes the matrix of unconditional forecasts, using the chain rule of forecasts (see technical guide p38)
% inputs:  - matrix 'data_endo_a': matrix of pre-forecast endogenous data
%          - matrix 'data_exo_p': predicted values for the exogenous variables over the forecast periods
%          - vector 'beta': vectorised form of VAR coefficients (definined in 1.1.12)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'horizon': number of forecast periods
% outputs: - matrix 'forecast_matrix': matrix recording the forecast values



% uses the chain rule of forecasting, p38 of the technical guide


% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:);

% reshape beta to obtain B
B=reshape(beta,k,n);


% repeat the process for periods T+1 to T+h
for jj=1:horizon


% step 1
% use the function lagx to obtain the matrix temp
temp=lagx(Y,p-1);


% step 2
% define the reduced regressor matrix X
% if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
if isempty(data_exo_p)==1
X=[temp(end,:)];
% if there are exogenous variables, concatenate them next to the endogenous
else
X=[temp(end,:) data_exo_p(jj,:)];
end


% step 3
% obtain the predicted value for T+jj
yp=X*B;


% step 4
% concatenate yp to the top of Y
Y=[Y;yp];

% repeat until values are obtained for T+h
end

% record the values in the matrix forecastmatrix
forecastmatrix=Y(p+1:end,:);

