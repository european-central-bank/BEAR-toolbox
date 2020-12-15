function [forecastmatrix]=TVEmaforecastsim(data_endo_a,B,p,n,Fcperiods,theta,TVEHfuture,tempeq,indH)


% function [forecastmatrix]=maforecastsim(data_endo_a,data_exo_a,data_exo_p,B,Delta,p,n,m,horizon)
% computes the matrix of unconditional forecasts (absent shocks)
% inputs:  - matrix 'data_endo_a': the matrix storing the pre-forecast endogenous data
%          - matrix 'data_exo_a': the matrix storing the pre-forecast exogenous data
%          - matrix 'data_exo_p': the matrix storing the predicted exogenous data
%          - matrix 'B': the matrix containing the VAR coefficients defined in (3.5.10)
%          - matrix 'Delta': the matrix containing the coefficients on exogenous data, defined in (3.5.10)
%          - integer 'p': the number of lags in the model
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'Fcperiods': the number of periods for which forecasts have to be produced
% outputs: - matrix 'forecastmatrix': the matrix storing the unconditional forecast values


% this function uses the chain rule of forecasts, defined p 38 of the user's guide, adapted for the mean_adjusted BVAR model


% compute the matrix Y
temp1=data_endo_a(end-p+1:end,:);   % last  p periods of data_endo_a
yhattemp=temp1-tempeq;              % deviation from equilibrium
temp1=reshape(yhattemp(sort(1:p,'descend'),:)',1,n*p);% compute the matrix exo

%for it=1:horizon
for it=1:Fcperiods
    futeq(it,:)=(squeeze(TVEHfuture(:,:,indH(end),it))*theta)'; % compute the equilibrium values given theta
end


% repeat the process for periods T+1 to T+h

for jj=1:Fcperiods

    
   yhattemp=temp1*B;    
   % obtain predicted value for T+jj by using (3.5.9)
   yhatforc(jj,:)=yhattemp;

   % concatenate the transpose of yp to the top of temp1
%    temp1=[yhattemp temp1(1:n)];   % old version
   temp1=[yhattemp temp1(1:(n*p-n))];     % as changed on 2018 05 
% % % % concatenate the transpose of predicted exogenous to the top of actual exogenous

% % % % use the function lagx on Y to obtain the matrix X; retain only the last row
% % % X=lagx(Y,p-1);
% % % X=X(end,:);
% % % 
% % % % use the function lagx on exo to obtain the matrix Z; retain only the last row
% % % 
% % % 
% % % % obtain predicted value for T+jj
% % % yp=X*B;
% % % 
% % % % concatenate the transpose of yp to the top of Y
% % % Y=[Y;yp];
% % % 
% % % % repeat until values are obtained for T+h
end

% record the values in the matrix forecastmatrix
forecastmatrix=yhatforc;



