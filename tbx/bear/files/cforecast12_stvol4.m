function [cforecast_record,strshocks_record]=cforecast12_stvol4(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q,Psi_gibbs, sizetraining, dataValues, Fstartlocation, Fendsmpl,Psi_median)

%determine the number of periods for which the local mean is available when the forecasts starts

size_estimation = size(data_endo_a,1);
size_available  = size_estimation - sizetraining+p;


% create first the cell storing the results
forecast_record=cell(n,1);

Mz=size(dataValues.Ppsi,1); %get the number of variables with survey local mean

%create the state space matrices
[KFSmatrices] = makeMatricesSLMfullSV(dataValues,p);
Zv1=KFSmatrices.Zmatrix(Mz+1:end,:); %Meausrement equation matrix 
Rv1=KFSmatrices.R;                   %variance covariance of transition equation
% Lv1=KFSmatrices.L;
TmatrixV1=KFSmatrices.Tmatrix;       %State transition matrix 
Rv1(1:n,:) = 0; % Psi will be constant over the forecast horizon
% compute the reduced matrix Y
Y=data_endo_a(end-p+1:end,:);

%% start of the gibbs sampler

for ii=1:It-Bu

%% draw parameters 
%get the draw for the unconditional mean
%if Fendsmpl==1
% for kk=1:n
%     Psi(:,kk) = Psi_gibbs{1,kk}(end-p+1:end,ii);
% end 
% else %this needs to be the value of the local mean at Fstartlocation-sizetraining+2*p
% for kk=1:n
%     Psi(:,kk) = Psi_gibbs{1,kk}(Fstartlocation-sizetraining+p:Fstartlocation-sizetraining+2*p-1,ii);
% end     
% end 
if Fendsmpl==1
for kk=1:n
     Psi(:,kk) = Psi_median(end-p+1:end,kk);
end 
else %this needs to be the value of the local mean at Fstartlocation-sizetraining+2*p
for kk=1:n
     Psi(:,kk) = Psi_median(Fstartlocation-sizetraining+p:Fstartlocation-sizetraining+2*p-1,kk);
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

%% get the unconditional forecast
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

    %forecast the state space
    
    %forecast state space
    yp=TmatrixV1*X';
    
    % concatenate the transpose of yp to the top of Y
    Yp=[Yp,yp];

    %set X to yp and go for next iteration
    X = yp';
   % repeat until values are obtained for T+h
   end
   
   %use the state space matrices to ultimately get the level
   %forecast for the n variables (in levels)
   for kk=1:n
   fmat(:,kk)=(Zv1(kk,1:end)*Yp)';
   end 
%% compute impulse responses 
D=reshape(D_record(:,ii),n,n);
gamma=reshape(gamma_record(:,ii),n,n);
[~,ortirfmat]=irfsim(beta,D,n,m,p,k,Fperiods);

%% draw the shocks such that the conditional forecast is fulfilled
%obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
   % if the user selected the basic setting (all the shocks are used)
   if CFt==1
   eta=shocksim1(cfconds,Fperiods,n,fmat,ortirfmat);
   % if instead the user selected the shock-specific setting
   elseif CFt==2
   eta=shocksim2(cfconds,cfshocks,cfblocks,Fperiods,n,gamma,fmat,ortirfmat);
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
      temp=temp+ortirfmat(:,:,jj-kk+1)*eta(:,kk);
      end
   % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
   cdforecast(jj,:)=fmat(jj,:)+temp';
end
clear temp
clear fmat

% step 6: record the results from current iteration in the cell cforecast_record
   % loop over variables
   for jj=1:n
   % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
   % record these values in the corresponding matrix of cforecast_record
   cforecast_record{jj,1}(ii,:)=cdforecast(:,jj)';
   strshocks_record{jj,1}(ii,:)=eta(jj,:);
   end
end 

end

