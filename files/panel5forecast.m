function [forecast_record,forecast_estimates]=panel5forecast(N,n,p,data_endo_a,data_exo_p,It,Bu,theta_gibbs,sigma_gibbs,Xi,Fperiods,const,Fband)















% create first the cells storing the results
forecast_record={};
forecast_estimates={};

% other preliminary tasks: generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
else
end


% run the Gibbs sampler for the forecasts
for ii=1:It-Bu

% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:);

% step 2: draw sigma from its posterior distribution
sigma=reshape(sigma_gibbs(:,ii),N*n,N*n);

% step 3: draw theta from its posterior distribution
theta=theta_gibbs(:,ii);


   % step 4: generate forecasts recursively
   % for each iteration ii, repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

   % use the function lagx to obtain the matrix temp
   temp=lagx(Y,p-1);

   % define the reduced regressor matrix X
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
   if isempty(data_exo_p)==1
   X=[temp(end,:)];
   % if there are exogenous variables, concatenate them next to the endogenous
   else
   X=[temp(end,:) data_exo_p(jj,:)];
   end

   % step 5: draw the residuals
   res=mvnrnd(zeros(N*n,1),sigma);

   % step 6: obtain Xtilde
   Xbar=kron(speye(N*n),X);
   Xtilde=Xbar*Xi;

   % step 7: obtain predicted value for T+jj
   yp=(Xtilde*theta)'+res;

   % concatenate the transpose of yp to the top of Y
   Y=[Y;yp];

   % repeat until values are obtained for T+h
   end

   % step 5: record the results from current iteration in the cell forecast_record
   % loop over units
   for jj=1:N
      % loop over variables
      for kk=1:n 
      % consider column (jj-1)*n+kk of matrix Y and trim the p initial values: what remains is the predicted values for the period T+1 to T+h, for variable kk, unit jj
      temp1=Y(p+1:end,(jj-1)*n+kk);
      % record these values in the corresponding matrix of forecast_record
      forecast_record{kk,1,jj}(ii,:)=temp1';
      end
   end

end


% then obtain point estimates and credibility intervals
% loop over units
for ii=1:N
forecast_estimates(:,:,ii)=festimates(forecast_record(:,:,ii),n,Fperiods,Fband);
end




