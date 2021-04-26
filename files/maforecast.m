function [forecast_record]=maforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,delta_gibbs,Fperiods,n,m,p,k1,k3)




% function [forecast_record]=maforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,delta_gibbs,Fperiods,n,m,p,k1,k3)
% computes draws from the posterior predictive distribution, that is, from the posterior distribution of forecasts
% inputs:  - matrix 'data_endo_a': the matrix storing the pre-forecast endogenous data
%          - matrix 'data_exo_a': the matrix storing the pre-forecast exogenous data
%          - matrix 'data_exo_p': the matrix storing the predicted exogenous data
%          - integer 'It': the total number of iterations run by the Gibbs sampler
%          - integer 'Bu': the number of initial iterations discared as burn-in sample
%          - matrix 'beta_gibbs': the matrix recording the post-burn draws of beta
%          - matrix 'sigma_gibbs': the matrix recording the post-burn draws of sigma
%          - matrix 'delta_gibbs': the matrix recording the post-burn draws of delta
%          - integer 'Fperiods': the number of periods for which forecasts have to be produced
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'p': the number of lags in the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
%          - integer 'k3': the number of coefficients related to the exogenous variables for each equation, in the reformulated model (3.5.5)
% outputs: - cell 'forecast_record': the cell array containing records of simulated  forecasts


% this function implements algorithm 2.1.1, adapted for the mean-adjusted BVAR model


% create first the cell storing the results
forecast_record=cell(n,1);


% generate the matrix of predicted exogenous variables 
% augment the matrices of exogenous with a column of ones to account for the exogenous
data_exo_a=[ones(size(data_endo_a,1),1) data_exo_a];
data_exo_p=[ones(Fperiods,1) data_exo_p];


% then start simulations
% repeat the process a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu


% compute the matrix temp1 
temp1=data_endo_a(end-p+1:end,:);


% compute the matrix temp2
temp2=[data_exo_a(end-p+1:end,:)];


% step 2: draw beta and sigma
% draw beta from its posterior distribution
beta=beta_gibbs(:,ii);
% reshape
B=reshape(beta,k1,n);


% draw delta from its posterior distribution
delta=delta_gibbs(:,ii);
% reshape
Delta=reshape(delta,k3,n);

% draw sigma from its posterior distribution
sigma=sigma_gibbs(:,ii);
% reshape sigma to recover its original square form
sigma=reshape(sigma,n,n);


   % step 4: generate forecasts recursively
   % repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

   % concatenate the predicted exogenous to the top of temp2 (the actual exogenous)
   temp2=[temp2;data_exo_p(jj,:)];

   % use the function lagx on temp1 to obtain the matrix Y; retain only the last row
   X=lagx(temp1,p-1);
   X=X(end,:);

   % use the function lagx on temp2 to obtain the matrix Z; retain only the last row
   Z=lagx(temp2,p);
   Z(:,m+1:end)=-Z(:,m+1:end);
   Z=Z(end,:);

   % draw the residuals from N(0,sigma)
   res=trns(chol(nspd(sigma),'Lower')*randn(n,1));
   
   % obtain predicted value for T+jj by using (3.5.9)   
   yp=X*B+Z*Delta+res;

   % concatenate the transpose of yp to the top of temp1
   temp1=[temp1;yp];

   % repeat until values are obtained for T+h
   end

% step 5: record the results from current iteration in the cell forecast_record
   % loop over variables
   for kk=1:n
   % consider column kk of matrix temp1 and select the last h rows: these are the predicted values for the period T+1 to T+h, for variable kk
   temp3=temp1(end-Fperiods+1:end,kk);
   % record these values in the corresponding matrix of forecast_record
   forecast_record{kk,1}(ii,:)=temp3';
   end

% then go for next iteration
end



