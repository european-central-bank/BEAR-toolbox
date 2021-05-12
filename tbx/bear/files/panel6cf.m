function [cforecast_record cforecast_estimates]=panel6cf(N,n,m,p,k,d,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,Xi,data_exo_p,theta_gibbs,B_gibbs,phi_gibbs,Zeta_gibbs,sigmatilde_gibbs,Fstartlocation,Ymat,rho,thetabar,gama,CFt,Fband)











% preliminary tasks: generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous (both actual and predicted) with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
end
% obtain the location of the final sample period before the beginning of the forecasts
finalp=Fstartlocation-1;
% obtain the value of ybarT
ybarT=vec(flipud(Ymat(finalp-p+1:finalp,:))');


% start simulations
for ii=1:It-Bu


% first recover the VAR coefficient values for each period
% recover theta for the final period before forecast
theta=theta_gibbs(:,ii,finalp);
% then recover B
B=reshape(B_gibbs(:,ii),d,d);
% obtain its choleski factor as the square of each diagonal element
cholB=diag(diag(B).^0.5);

% obtain the values for theta for each forecast period
% initiate the recording of theta values
theta_iter=[];
   % loop over forecast periods
   for jj=1:Fperiods
   % obtain a shock eta
   eta=cholB*mvnrnd(zeros(d,1),eye(d))';
   % update theta from its AR process
   theta=(1-rho)*thetabar+rho*theta+eta;
   % record
   theta_iter=[theta_iter theta];
   end


% obtain similarly the value for sigma and D for each forecast period
% recover sigmatilde
sigmatilde=reshape(sigmatilde_gibbs(:,ii),N*n,N*n);
% recover phi
phi=phi_gibbs(1,ii);
% initiate zeta
zeta=Zeta_gibbs(finalp,ii);
% initiate the recording of sigma values and D values
sigma_iter=[];
D_iter=[];
gamma_iter=[];
   % loop over forecast periods
   for jj=1:Fperiods
   % obtain a shock upsilon
   ups=normrnd(0,phi); 
   % update zeta from its law of motion
   zeta=gama*zeta+ups;
   % update sigma
   sigma_iter(:,:,jj)=exp(zeta)*sigmatilde;
   % obtain the structural decomposition matrix
   D_iter(:,:,jj)=chol(nspd(sigma_iter(:,:,jj)),'lower');
   % obtain the variance-covariance matrix of the structural disturbances (identity for a Choleski scheme)
   gamma_iter(:,:,jj)=eye(N*n);
   end


% obtain the unconditional forecasts and the orthogonalised impulse response functions
[fmat ortirfcell]=panel6cfsim(theta_iter,D_iter,Xi,ybarT,data_exo_p,Fperiods,N,n,m,p,k);


% obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
   % if the user selected the basic setting (all the shocks are used)
   if CFt==1
   eta=shocksim3(cfconds,Fperiods,N,n,fmat,ortirfcell);
   % if instead the user selected the shock-specific setting
   elseif CFt==2
   eta=shocksim4(cfconds,cfshocks,cfblocks,Fperiods,N,n,gamma_iter,fmat,ortirfcell);
   end
eta=reshape(eta,N*n,Fperiods);


% obtain the conditional forecasts
% loop over periods
   for jj=1:Fperiods
   % compute shock contribution to forecast values
   % create a temporary vector of cumulated shock contributions
   temp=zeros(N*n,1);
   % loop over periods up the the one currently considered
      for kk=1:jj
      temp=temp+ortirfcell{jj-kk+1,jj}(:,:)*eta(:,kk);
      end
   % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
   cdforecast(jj,:)=fmat(jj,:)+temp';
end
clear temp


% record the results from current iteration in the cell cforecast_record
   % loop over variables
   for jj=1:N*n
   % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
   % record these values in the corresponding matrix of cforecast_record
   cforecast_record{jj,1}(ii,:)=cdforecast(:,jj)';
   end


% then go for next iteration
end


% obtain point estimates and credibility interval
[cforecast_estimates]=festimates(cforecast_record,N*n,Fperiods,Fband);


% reorganise to obtain a record similar to that of the unconditional forecasts
cforecast_record=reshape(cforecast_record,n,1,N);
cforecast_estimates=reshape(cforecast_estimates,n,1,N);










