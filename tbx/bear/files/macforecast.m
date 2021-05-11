function [cforecast_record]=macforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,n,m,p,k1,k3,beta_gibbs,delta_gibbs,D_record,gamma_record)



% function [cforecast_record]=macforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,n,m,p,k1,k3,beta_gibbs,delta_gibbs,D_record,gamma_record)
% runs the gibbs sampler to obtain draws from the posterior predictive distribution, that is the distribution of conditional forecasts
% inputs:  - matrix 'data_endo_a': matrix of pre-forecast endogenous data
%          - matrix 'data_exo_a': matrix of pre-forecast exogenous data
%          - matrix 'data_exo_p': predicted values for the exogenous variables over the forecast periods
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Fperiods': number of forecast periods
%          - cell 'cfconds': conditional forecast conditions
%          - cell 'cfshocks': conditional forecast shocks generating the conditions
%          - matrix 'cfblocks': conditional forecast blocks
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k1': number of endogenous coefficients to estimate for each equation in the MABVAR model (defined p 77 of technical guide)
%          - integer 'k3': number of exogenous coefficients to estimate for each equation in the reformulated MABVAR model (defined p 77 of technical guide)
%          - matrix 'beta_gibbs': the matrix recording the post-burn draws of beta
%          - matrix 'delta_gibbs': the matrix recording the post-burn draws of delta
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
% outputs: - cell 'cforecast_record': record of the gibbs sampler draws for the conditional forecasts




% this function implements algorithm 3.4.2, adapted for mean-adjusted BVAR models


% preliminary tasks

% create first the cell storing the results
cforecast_record=cell(n,1);

% generate the matrix of predicted exogenous variables 
% augment the matrices of exogenous with a column of ones to account for the exogenous
data_exo_a=[ones(size(data_endo_a,1),1) data_exo_a];
data_exo_p=[ones(Fperiods,1) data_exo_p];



% start simulations
for ii=1:It-Bu


% step 1: attribute values for B, Delta, D and gamma
B=reshape(beta_gibbs(:,ii),k1,n);
Delta=reshape(delta_gibbs(:,ii),k3,n);
D=reshape(D_record(:,ii),n,n);
gamma=reshape(gamma_record(:,ii),n,n);


% step 2: compute regular forecasts for the data (without shocks)
fmat=maforecastsim(data_endo_a,data_exo_a,data_exo_p,B,Delta,p,n,m,Fperiods);


% step 3: compute IRFs and orthogonalised IRFs matrices
[~,ortirfmat]=mairfsim(B,D,p,n,Fperiods);


% step 4: obtain the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
   % if the user selected the basic setting (all the shocks are used)
   if CFt==1
   eta=shocksim1(cfconds,Fperiods,n,fmat,ortirfmat);
   % if instead the user selected the shock-specific setting
   elseif CFt==2
   eta=shocksim2(cfconds,cfshocks,cfblocks,Fperiods,n,gamma,fmat,ortirfmat);
   end
eta=reshape(eta,n,Fperiods);


% step 5: obtain the conditional forecasts
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


% step 6
   % record the results from current iteration in the cell cforecast_record
   % loop over variables
   for jj=1:n
   % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
   % record these values in the corresponding matrix of cforecast_record
   cforecast_record{jj,1}(ii,:)=cdforecast(:,jj)';
   end


% then go for next iteration
end





