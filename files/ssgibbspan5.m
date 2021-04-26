function [ss_record ss_estimates]=ssgibbspan5(n,N,m,p,k,T,Xmat,theta_gibbs,Xi,It,Bu,cband)








% first create the cell storing the steady-state draws
ss_record=cell(n,N);

% then compute the preliminary element Nn
Nn=N*n;

% run the Gibbs sampler
for ii=1:It-Bu

% draw beta from its posterior distribution
% recover it from the structural factors
beta=Xi*theta_gibbs(:,ii);

% recover the coefficient matrices A1,...,Ap and C
% first, calculate B and take its transpose BT
BT=reshape(beta,k,Nn)';

% estimate the summation term I-A1-...-Ap
summation=eye(Nn);
   for jj=1:p
   summation=summation-BT(:,(jj-1)*Nn+1:jj*Nn);
   end

% recover C
C=BT(:,end-m+1:end);

% now calculate the product of the inverse of the summation with C
product=summation\C;

% keep only the exogenous regressor part of X
X_exo=Xmat(:,end-m+1:end)';

% compute the steady-state values from (a.7.6)
ssvalues=product*X_exo;
% reshape for convenience
ssvalues=reshape(ssvalues',T,n,N);

   % record the value in the cell ss_record
   % loop over units
   for jj=1:N
      % loop over variables
      for kk=1:n
      ss_record{kk,jj}(ii,:)=ssvalues(:,kk,jj)';
      end
   end
end



% then obtain point estimates
% create first the cell that will contain the estimates
ss_estimates=cell(n,N);

% for each variable and each sample period, compute the median, lower and upper bound from the Gibbs sampler records
% loop over units
for ii=1:N
   % consider variables in turn
   for jj=1:n
      % consider sample periods in turn
      for kk=1:T
      % compute first the lower bound
      ss_estimates{jj,ii}(1,kk)=quantile(ss_record{jj,ii}(:,kk),(1-cband)/2);
      % then compute the median
      ss_estimates{jj,ii}(2,kk)=quantile(ss_record{jj,ii}(:,kk),0.5);
      % finally compute the upper bound
      ss_estimates{jj,ii}(3,kk)=quantile(ss_record{jj,ii}(:,kk),(1-(1-cband)/2));
      end
   end
end





