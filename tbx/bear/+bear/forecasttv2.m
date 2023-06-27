function [forecast_record]=forecasttv2(data_endo_a,data_exo_p,It,Bu,beta_gibbs,omega_gibbs,F_gibbs,phi_gibbs,L_gibbs,gamma,sbar,Fstartlocation,Fperiods,n,p,k,q,const)





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
Y=data_endo_a(end-p+1:end,:);


% step 3: draw beta, omega and sigma and F from their posterior distributions
% draw beta
beta=beta_gibbs{Fstartlocation-1,1}(:,ii);
% draw omega
omega=omega_gibbs(:,ii);
% create a choleski of omega, the variance matrix for the law of motion
cholomega=sparse(diag(omega));
% draw F from its posterior distribution
F=sparse(F_gibbs(:,:,ii));
% step 4: draw phi from its posterior
phi=phi_gibbs(ii,:)';
% also, compute the pre-sample value of lambda, the stochastic volatility process
lambda=L_gibbs(Fstartlocation-1,:,ii)';


   % then generate forecasts recursively
   % for each iteration ii, repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

   % update beta
   beta=beta+cholomega*randn(q,1);
   % reshape it to obtain B
   B=reshape(beta,k,n);
       
   % use the function lagx to obtain the matrix temp
   temp=bear.lagx(Y,p-1);
   % define the reduced regressor matrix X
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
      if isempty(data_exo_p)==1
      X=[temp(end,:)];
      % if there are exogenous vaiables, concatenate them next to the endogenous
      else
      X=[temp(end,:) data_exo_p(jj,:)];
      end

   % update lambda_t and obtain Lambda_t
   % loop over variables
      for kk=1:n
      lambda(kk,1)=gamma*lambda(kk,1)+phi(kk,1)^0.5*randn;
      end
   % obtain Lambda_t
   Lambda=sparse(diag(sbar.*exp(lambda)));
   
   
   % recover sigma_t and draw the residuals
   sigma=full(F*Lambda*F');
   % draw the vector of residuals
   res=bear.trns(chol(bear.nspd(sigma),'Lower')*randn(n,1));

   % obtain predicted value for T+jj
   yp=X*B+res;

   % concatenate the transpose of yp to the top of Y
   Y=[Y;yp];

   % step 8: repeat until values are obtained for T+h
   end

   
   % record the results from current iteration in the cell forecast_record
   % loop over variables
   for kk=1:n
   % consider column kk of matrix Y and trim the p initial values: what remains is the predicted values for the period T+1 to T+h, for variable kk
   temp1=Y(p+1:end,kk);
   % record these values in the corresponding matrix of forecast_record
   forecast_record{kk,1}(ii,:)=temp1';
   end

   
% step 9: repeat until It-Bu iterations are obtained
end

