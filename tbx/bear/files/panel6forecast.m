function [forecast_record,forecast_estimates]=...
    panel6forecast(const,data_exo_p,Fstartlocation,It,Bu,data_endo_a,p,B_gibbs,sigmatilde_gibbs,N,n,phi_gibbs,theta_gibbs,Zeta_gibbs,Fperiods,d,rho,thetabar,gama,Xi,Fband)









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
% identify the final period before the beginning of the forecasts: this is required to initiate the time-varying process
finalp=Fstartlocation-1;



% run the Gibbs sampler for the forecasts
for ii=1:It-Bu

% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:);

% recover B
B=reshape(B_gibbs(:,ii),d,d);
% obtain its choleski factor as the square of each diagonal element
cholB=diag(diag(B).^0.5);

% draw sigmatilde and phi
sigmatilde=reshape(sigmatilde_gibbs(:,ii),N*n,N*n);
phi=phi_gibbs(1,ii);

% initiate theta and zeta
theta=theta_gibbs(:,ii,finalp);
zeta=Zeta_gibbs(finalp,ii);



   % generate forecasts recursively
   % for each iteration jj, repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

   % update theta
   % draw the vector of shocks eta
   eta=cholB*mvnrnd(zeros(d,1),eye(d))';
   % update theta from its AR process
   theta=(1-rho)*thetabar+rho*theta+eta;

   % update sigma
   % draw the shock upsilon
   ups=normrnd(0,phi);
   % update zeta from its AR process
   zeta=gama*zeta+ups;
   % recover sigma
   sigma=exp(zeta)*sigmatilde;

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




