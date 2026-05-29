function [IRFcell]=tvhdsim(beta,D_iter,n,m,p,T,k)

% create first a T*1 cell for which each entry corresponds to one period
At=cell(T,1);
% then start filling At
for ii=1:T
% truncate the exogenous coefficients of beta (the m final rows) as they are not used    
temp=reshape(beta(:,ii),k,n);
temp=temp(1:end-m,:);
At{ii,1}=sparse([temp';speye(n*(p-1)) sparse(n*(p-1),n)]);
end


% now compute the period-specific irfs
% first create the cell storing the results
IRFcell=cell(T,T);
% create the selection matrix J
J=[speye(n) sparse(n,n*(p-1))];

% loop over sample period
for tt=1:T
% the first row of the cell represents the (orthogonalised) response to contemporary shocks: it is always D
IRFcell{1,tt}=D_iter(:,:,tt);
   % loop over IRF periods
   for ii=1:tt-1
   % initiate the product
   product=speye(n*p);
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





