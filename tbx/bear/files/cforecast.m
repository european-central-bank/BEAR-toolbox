function [cforecast_record,strshocks_record]=cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,CFt,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q)



% function [cforecast_record]=cforecast(data_endo_a,data_exo_a,data_exo_p,It,Bu,Fperiods,cfconds,cfshocks,cfblocks,const,beta_gibbs,D_record,gamma_record,n,m,p,k,q)
% runs algorithm 3.4.2 and generates conditional forecast draws, for the Minnesota prior
% inputs:  - matrix 'data_endo_a': the matrix storing the pre-forecast endogenous data
%          - matrix 'data_exo_a': the matrix storing the pre-forecast exogenous data
%          - matrix 'data_exo_p': the matrix storing the predicted exogenous data
%          - integer 'It': the total number of iterations run by the Gibbs sampler
%          - integer 'Bu': the number of initial iterations discared as burn-in sample
%          - integer 'Fperiods': the number of periods for which forecasts have to be produced
%          - cell 'cfconds': the cell containing the conditions (constrained values) on future periods
%          - cell 'cfshocks': the cell containing the list of shocks associated with each condition
%          - matrix 'cfblocks': the matrix containing the list of the blocks for the variables with a condition
%          - integer 'CFt': the type of conditional forecast selected by the user: general or shock-specific
%          - integer 'const': 0-1 value determining whether a constant term should be included in the model
%          - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'p': the number of lags in the model
%          - integer 'k': the number of VAR coefficients to be estimated for each equation in the model
%          - integer 'q': the total number of VAR coefficients to be estimated
% outputs: - cell 'cforecast_record': the cell array containing records of simulated  conditional forecasts




% preliminary tasks: generate the matrix of predicted exogenous variables
% if the constant has been retained, augment the matrices of exogenous (both actual and predicted) with a column of ones:
if const==1
data_exo_a=[ones(size(data_endo_a,1),1) data_exo_a];
data_exo_p=[ones(Fperiods,1) data_exo_p];
% if no constant was included, do nothing
end




% start simulations
for ii=1:It-Bu


% step 1: attribute values for beta, D and gamma
beta=beta_gibbs(:,ii);
D=reshape(D_record(:,ii),n,n);
gamma=reshape(gamma_record(:,ii),n,n);


% step 2: compute regular forecasts for the data (without shocks)
fmat=forecastsim(data_endo_a,data_exo_p,beta,n,p,k,Fperiods);


% step 3: compute IRFs and orthogonalised IRFs matrices
[~,ortirfmat]=irfsim(beta,D,n,m,p,k,Fperiods);


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


% step 6: record the results from current iteration in the cell cforecast_record
   % loop over variables
   for jj=1:n
   % consider column jj of matrix cdforecast: it contains forecasts for variable jj, from T+1 to T+h
   % record these values in the corresponding matrix of cforecast_record
   cforecast_record{jj,1}(ii,:)=cdforecast(:,jj)';
   strshocks_record{jj,1}(ii,:)=eta(jj,:);
   end


% then go for next iteration
end

