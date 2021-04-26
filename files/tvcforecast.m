function [cforecast_record]=tvcforecast(n,m,p,k,q,cfconds,cfshocks,cfblocks,It,Bu,Fperiods,const,data_exo_p,beta_gibbs,omega_gibbs,sigma_gibbs,D_record,gamma_record,Fstartlocation,Y,CFt)











% preliminary tasks: generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous (both actual and predicted) with a column of ones:
if const==1
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
end
% obtain the location of the final sample period before the beginning of the forecasts
finalp=Fstartlocation-1;
% obtain the value of ybarT
ybarT=vec(flipud(Y(finalp-p+1:finalp,:))');


% start simulations
for ii=1:It-Bu


% first recover the VAR coefficient values for each period
% recover theta for the final period before forecast
beta=beta_gibbs{finalp,1}(:,ii);
% then recover omega
omega=omega_gibbs(:,ii);
% obtain its choleski factor as the square of each diagonal element
cholomega=omega.^0.5;  
    


% obtain the values for beta for each forecast period
% initiate the recording of beta values
beta_iter=[];
   % loop over forecast periods
   for jj=1:Fperiods
   % update beta
   beta=beta+cholomega.*randn(q,1);
   % record
   beta_iter=[beta_iter beta];
   end


% obtain similarly the value for sigma and D for each forecast period
% recover sigma
sigma=reshape(sigma_gibbs(:,ii),n,n);
% recover D
D=reshape(D_record(:,ii),n,n);
gamma=reshape(gamma_record(:,ii),n,n);



% obtain the unconditional forecasts and the orthogonalised impulse response functions
[fmat ortirfcell]=tvcfsim1(beta_iter,D,ybarT,data_exo_p,Fperiods,n,m,p,k);


% obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
   % if the user selected the basic setting (all the shocks are used)
   if CFt==1
   eta=shocksim5(cfconds,Fperiods,n,fmat,ortirfcell);
   % if instead the user selected the shock-specific setting
   elseif CFt==2
   eta=shocksim6(cfconds,cfshocks,cfblocks,Fperiods,n,gamma,fmat,ortirfcell);
   end
eta=reshape(eta,n,Fperiods);


% obtain the conditional forecasts
% loop over periods
   for jj=1:Fperiods
   % compute shock contribution to forecast values
   % create a temporary vector of cumulated shock contributions
   temp=zeros(n,1);
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
   for jj=1:n
   % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
   % record these values in the corresponding matrix of cforecast_record
   cforecast_record{jj,1}(ii,:)=cdforecast(:,jj)';
   end


% then go for next iteration
end









