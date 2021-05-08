function [forecast_record]=forecaststvol4(dataValues, data_endo_a,data_exo_p,It,Bu,beta_gibbs,F_gibbs,phi_gibbs,phi_V_gibbs,V_gibbs, Psi_gibbs, L_gibbs,gamma,Fstartlocation,Fperiods,n,p,k,sizetraining, Fendsmpl)

%determine the number of periods for which the local mean is available when the forecasts starts

size_estimation = size(data_endo_a,1);
size_available  = size_estimation - sizetraining+p;


forecast_local_mean = 0;
% create first the cell storing the results
forecast_record=cell(n,1);

Mz=size(dataValues.Ppsi,1); %get the number of variables with survey local mean

%create the state space matrices
[KFSmatrices] = makeMatricesSLMfullSV(dataValues,p);
Zv1=KFSmatrices.Zmatrix(Mz+1:end,:); %Meausrement equation matrix 
Rv1=KFSmatrices.R;                   %variance covariance of transition equation
% Lv1=KFSmatrices.L;
TmatrixV1=KFSmatrices.Tmatrix;       %State transition matrix 

if forecast_local_mean == 0 
    Rv1(1:n,:) = 0; % Psi will be constant over the forecast horizon
end

% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:);

for ii=1:It-Bu

if Fendsmpl==1
for kk=1:n
    Psi(:,kk) = Psi_gibbs{1,kk}(end-p+1:end,ii);
end 
else %this needs to be the value of the local mean at Fstartlocation-sizetraining+2*p
for kk=1:n
    Psi(:,kk) = Psi_gibbs{1,kk}(Fstartlocation-sizetraining+p:Fstartlocation-sizetraining+2*p-1,ii);
end     
end 

%now use the local mean to get the variables in deviation from the mean
Ytilde = Y-Psi;

% step 3: draw beta and F from their posterior distributions 
beta=beta_gibbs(:,ii);
% reshape it to obtain B
B=reshape(beta,k,n);
%and set the state transition equation matrix
TmatrixV1(n+1:2*n,n+1:end) = B';  
% draw F from its posterior distribution
F=sparse(F_gibbs(:,:,ii));

% step 4: draw phi from its posterior
phi=phi_gibbs(ii,:)';
phi_V=phi_V_gibbs(ii,:)';

% also, compute the pre-sample value of lambda, the stochastic volatility
% process of the VAR residuals
lambda=L_gibbs(Fstartlocation-sizetraining+p+p-1,:,ii)';
% and the state transition equation
V = V_gibbs(Fstartlocation-sizetraining+p+p-1,:,ii)';

Yp=[]; %iniate forecast saving matrix

%initate RHS
 % use the function lagx to obtain the matrix temp
   temp=lagx(Ytilde,p-1);
   % define the reduced regressor matrix X
   % if no exogenous variable is present at all in the model (neither constant nor other exogenous), define X only from the endogenous variables
      if isempty(data_exo_p)==1
      X=[temp(end,:)];
      % if there are exogenous vaiables, concatenate them next to the endogenous
      else
      X=[temp(end,:) data_exo_p(jj,:)];
      end
  %also concantenate the last in sample estimates of the local mean 
    X=[Psi(end,:),X]; 
    
% then generate forecasts recursively
   % for each iteration ii, repeat the process for periods T+1 to T+h
   for jj=1:Fperiods

      if ~isempty(data_exo_p)==1
      X=[X data_exo_p(jj,:)];
      end
    
   % step 5: update lambda_t and obtain Lambda_t
   % loop over variables
      for kk=1:n
      loglambda(kk,1)=1*log(lambda(kk,1))+phi(kk,1)^0.5*randn;
      end
   % obtain Lambda_t
   lambda=exp(loglambda);

   
   % step 6: recover sigma_t and draw the residuals
   sigma=full(F*diag(lambda)*F');
   % draw the vector of residuals
   res=trns(chol(nspd(sigma),'Lower')*randn(n,1));

   %step 7: update V_t
    stdPhi=diag(phi_V.^0.5);
    logV=log(V)+stdPhi*randn(n,1);
    V=(exp(logV));   
    
    %step 8 forecast the state space
    
    %forecast state space
    yp=TmatrixV1*X'+Rv1*[sqrt(V).*randn(n,1); res'];
    
    % concatenate the transpose of yp to the top of Y
    Yp=[Yp,yp];

    %set X to yp and go for next iteration
    X = yp';
   % step 8: repeat until values are obtained for T+h
   end
   
   %step 9: use the state space matrices to ultimately get the level
   %forecast for the n variables (in levels)
   for kk=1:n
   forecast_record{kk,1}(ii,:)=(Zv1(kk,1:end)*Yp);
   end    

    
    


end 



