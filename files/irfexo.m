function [exo_irf_record,exo_irf_estimates]=irfexo(beta_gibbs,It,Bu,IRFperiods,IRFband,n,m,p,k,prior)



% create the cell aray that will store the values from the simulations
exo_irf_record=cell(n,m);


% deal with shocks in turn
for ii=1:m


   % step 1: repeat the simulation process a number of times equal to the number of Gibbs iterations
   for kk=1:It-Bu


   % step 3: draw beta from its posterior distribution
   beta=beta_gibbs(:,kk);
   % reshape to obtain B
   B=reshape(beta,k,n);
   % recover C, the matrix of coefficients on exogenous
   C=B(end-m+1:end,:);
   % create a matrix of zeros of dimension p*n
   Y=zeros(p,n);
   %  step 2: set the value of the last row, column i, equal to 1
   Y(p,:)=C(ii,:);


      % step 4: for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for jj=1:IRFperiods-1
% % %           if prior==61
% % %          %use the function lagx to obtain the matrix X; retain only the last row
% % %    X=lagx(Y,p-1);
% % %    X=X(end,:);
% % % 
% % %           
% % %     else    
          

      % use the function lagx to obtain a matrix temp, containing the endogenous regressors
      temp=lagx(Y,p-1);

      % define the vector X
      X=[temp(end,:) zeros(1,m)];
% % %           end
      % obtain the predicted value for T+jj
      yp=X*B;

      % concatenate yp at the top of Y
      Y=[Y;yp];

      % repeat until values are obtained for T+h
      end


   % step 5: record the results from current iteration in cell irf_record
      % loop over variables
      for jj=1:n
      % consider column jj of matrix 'Y' and trim the (p-1) initial periods: what remains is the series of IRFs for period T to period T+h-1, for variable jj
      temp=Y(p:end,jj);
      % record these values in the corresponding matrix of irf_record
      exo_irf_record{jj,ii}(kk,:)=temp';
      end


   % then go for next iteration
   end

% conduct the same process with shocks in other variables
end


% create first the cell that will contain the IRF estimates
exo_irf_estimates=cell(n,m);

% for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider shocks in turn
   for jj=1:m
      % consider IRF periods in turn
      for kk=1:IRFperiods
      % compute first the lower bound
      exo_irf_estimates{ii,jj}(1,kk)=quantile(exo_irf_record{ii,jj}(:,kk),(1-IRFband)/2);
      % then compute the median
      exo_irf_estimates{ii,jj}(2,kk)=quantile(exo_irf_record{ii,jj}(:,kk),0.5);
      % finally compute the upper bound
      exo_irf_estimates{ii,jj}(3,kk)=quantile(exo_irf_record{ii,jj}(:,kk),1-(1-IRFband)/2);
      end
   end
end

