function [IRFcell]=panel6hdsim(theta_iter,D_iter,Xi,N,n,m,p,T,k)




% then obtain a matrix of beta coefficients (one column per equation, for each sample period)
Beta=reshape(Xi*theta_iter,k,T*N*n);
% truncate the exogenous coefficients (the m final rows) as they are not used
% then reshape into a 3d matrix to have one period per sheet
Beta=reshape(Beta(1:end-m,:),[k-m N*n T]);


% then define the At matrix for each period
% create a T*1 cell for which each entry corresponds to one period
% loop over time periods
At=cell(T,1);
for ii=1:T
At{ii,1}=sparse([Beta(:,:,ii)';speye(N*n*(p-1)) sparse(N*n*(p-1),N*n)]);
end


% now compute the period-specific irfs
% first create the cell storing the results
IRFcell=cell(T,T);
% create the selection matrix J
J=[speye(N*n) sparse(N*n,N*n*(p-1))];

% loop over sample period
for tt=1:T
% the first row of the cell represents the (orthogonalised) response to contemporary shocks: it is always D
IRFcell{1,tt}=D_iter(:,:,tt);
   % loop over IRF periods
   for ii=1:tt-1
   % initiate the product
   product=speye(N*n*p);
      % loop over the periods involved into the product and calculate it
      for jj=1:ii
      product=product*At{tt+1-jj,1};
      end
   % recover the matrix of interest from the selection matrix J
   IRFmat=full(J*product*J');
   % obtain orthogonalised IRFs
   ortIRFmat=IRFmat*D_iter(:,:,tt);
   % record in IRFcell
   IRFcell{ii+1,tt}=ortIRFmat;
   end
end





