function [forecast_record]=forecast_mf(data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const)



% function [forecast_record]=forecast(data_endo_a,data_exo_p,It,Bu,beta_gibbs,sigma_gibbs,Fperiods,n,p,k,const)
% runs the gibbs sampler to obtain draws from the posterior predictive distribution, that is the distribution of forecasts
% inputs:  - matrix 'data_endo_a': matrix of pre-forecast endogenous data
%          - matrix 'data_exo_p': predicted values for the exogenous variables over the forecast periods
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix'sigma_gibbs': record of the gibbs sampler draws for the sigma matrix (vectorised)
%          - integer 'Fperiods': number of forecast periods
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'const': 0-1 value to determine if a constant is included in the model
% outputs: - cell 'forecast_record': record of the gibbs sampler draws for the unconditional forecasts

% implements algorithm 2.1.1


% create first the cell storing the results
forecast_record=cell(n,1);

% other preliminary tasks: generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
else
end


% then start simulations
% repeat the process a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu


% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:,ii);            % The subscript here is redundant because we now feed in only the last part of the sample (the last p lags)


% step 2: draw beta and sigma
% draw beta from its posterior distribution
beta=beta_gibbs(:,ii);
% reshape it to obtain B
B=reshape(beta,k,n);
% draw sigma from its posterior distribution




sigma=sigma_gibbs(:,ii);
% reshape sigma to recover its original square form
sigma=reshape(sigma,n,n);


   % step 4: generate forecasts recursively
   % for each iteration ii, repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

   % use the function lagx to obtain the matrix temp
   temp=lagx(Y,p-1);

   % define the reduced regressor matrix X
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
   if isempty(data_exo_p)==1
   X=[temp(end,:)];
   % if there are exogenous vaiables, concatenate them next to the endogenous
   else
   X=[temp(end,:) data_exo_p(jj,:)];
   end

   % step 3:draw the residuals from N(0,sigma)
   res=trns(chol(nspd(sigma),'Lower')*randn(n,1));

   % obtain predicted value for T+jj
   yp=X*B+res;

   % concatenate the transpose of yp to the top of Y
   Y=[Y;yp];

   % repeat until values are obtained for T+h
   end

% step 5: record the results from current iteration in the cell forecast_record
   % loop over variables
   for kk=1:n
   % consider column kk of matrix Y and trim the p initial values: what remains is the predicted values for the period T+1 to T+h, for variable kk
   temp1=Y(p+1:end,kk);
   % record these values in the corresponding matrix of forecast_record
   forecast_record{kk,1}(ii,:)=temp1';
   end

% then go for next iteration
end



