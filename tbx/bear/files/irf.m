function [irf_record]=irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k)

% function [irf_record]=irf(beta_gibbs,It,Bu,IRFperiods,n,m,p,k)
% runs the gibbs sampler to obtain draws from the posterior distribution of IRFs
% inputs:  - matrix 'beta_gibbs': record of the gibbs sampler draws for the beta vector
%          - integer 'It': total number of iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'Bu': number of burn-in iterations of the Gibbs sampler (defined p 28 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: -  cell 'irf_record': record of the gibbs sampler draws for the IRFs


% this function implements algorithm 2.2.1

% create the cell aray that will store the values from the simulations
irf_record=cell(n,n);

Bgibbs=reshape(beta_gibbs,k,n,It-Bu);

% deal with shocks in turn
for ii=1:n

   % step 1: repeat the simulation process a number of times equal to the number of Gibbs iterations
   for kk=1:It-Bu

   % step 3: draw beta from its posterior distribution
   B=squeeze(Bgibbs(:,:,kk));
   % create a matrix of zeros of dimension p*n
   Y=zeros(p,n);
   %  step 2: set the value of the last row, column i, equal to 1
   Y(p,ii)=1;

% if prior~=61
      % step 4: for each iteration kk, repeat the algorithm for periods T+1 to T+h
      for jj=1:IRFperiods-1
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
% elseif prior==61 %for prior=61 mean adjusted model
% 	  % for each iteration kk, repeat the algorithm for periods T+1 to T+h
%       for jj=1:IRFperiods
%       % use the function lagx to obtain the matrix X
%       X=lagx(Y,p-1);
%       X=X(end,:);
%       % obtain predicted value for T+jj
%       yp=X*B;
%       % concatenate yp at the top of Y
%       Y=[Y;yp];
%       % repeat until values are obtained for T+h
%       end
% end

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

