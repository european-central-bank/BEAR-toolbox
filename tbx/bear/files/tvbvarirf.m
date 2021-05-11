function [irf_record]=tvbvarirf(beta_gibbs,omega_gibbs,It,Bu,IRFperiods,n,m,p,k,q,T)





% create the cell aray that will store the values from the simulations
irf_record=cell(n,n);


% deal with shocks in turn
for ii=1:n

   % step 1: repeat the simulation process a number of times equal to the number of Gibbs iterations
   for kk=1:It-Bu


   % step 3: draw beta from its posterior distribution
   beta=beta_gibbs{T,1}(:,kk);
   % create a choleski of omega, the variance matrix for the law of motion
   cholomega=sparse(diag(omega_gibbs(:,kk)));
   
   % create a matrix of zeros of dimension p*n
   Y=zeros(p,n);
   %  step 2: set the value of the last row, column i, equal to 1
   Y(p,ii)=1;


      % step 4: for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for jj=1:IRFperiods-1

      % update beta for period T+jj
      beta=beta+cholomega*randn(q,1);
          
      % reshape to obtain B
      B=reshape(beta,k,n); 
          
      % use the function lagx to obtain a matrix temp, containing the endogenous regressors
      temp=lagx(Y,p-1);

      % define the vector X
      X=[temp(end,:) zeros(1,m)];

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
      irf_record{jj,ii}(kk,:)=temp';
      end


   % then go for next iteration
   end

% conduct the same process with shocks in other variables
end



