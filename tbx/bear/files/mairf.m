function [irf_record]=mairf(beta_gibbs,It,Bu,IRFperiods,p,n,k1)




% function [irf_record]=mairf(beta_gibbs,It,Bu,IRFperiods,p,n,k1)
% produces draws from the posterior IRF distribution for a mean-adjusted VAR model
% inputs:  - matrix 'beta_gibbs': the matrix recording the post-burn draws of beta
%          - integer 'It': the total number of iterations run by the Gibbs sampler
%          - integer 'Bu': the number of initial iterations discared as burn-in sample
%          - integer 'IRFperiods': the number of periods for which IRFs are computed
%          - integer 'p': the number of lags in the model
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
% outputs: - cell 'irf_record': the cell recording the simulated IRFs



% this function implements algorithm 2.2.1, adapted to a mean_adjusted BVAR model



% create the cell aray that will store the values from the simulations
irf_record=cell(n,n);


% deal with shocks in turn
for ii=1:n


   % repeat the simulation process a number of times equal to irfsim
   for kk=1:It-Bu


   % draw beta from its posterior distribution
   beta=beta_gibbs(:,kk);
   % reshape to obtain B
   B=reshape(beta,k1,n);
   % create a matrix of zeros of dimension p*n
   Y=zeros(p,n);
   % set the value of the last row, column i, equal to 1
   Y(p,ii)=1;


      % for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for jj=1:IRFperiods

      % use the function lagx to obtain the matrix X
      X=lagx(Y,p-1);
      X=X(end,:);

      % obtain predicted value for T+jj
      yp=X*B;

      % concatenate yp at the top of Y
      Y=[Y;yp];

      % repeat until values are obtained for T+h
      end


   % record the results from current iteration in cell irf_record
      % loop over variables
      for jj=1:n
      % consider column jj of matrix 'Y' and and trim the (p-1) initial periods: what remains is the series of IRFs for period T to period T+h-1, for variable jj
      temp=Y(p:end,jj);
      % record these values in the corresponding matrix of irf_record
      irf_record{jj,ii}(kk,:)=temp';
      end


   % then go for next iteration
   end

% conduct the same process with shocks in other variables
end




