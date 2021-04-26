function eta=shocksim5(cfconds,Fperiods,n,fmat,ortirfcell)















% prelminary tasks: initiate R and r
R=[];
r=[];


% loop over forecast periods to build the matrix R and the vector r
for ii=1:Fperiods
   % for period ii, check if there is a condition, variable after variable
   for jj=1:n
      % if there is a condition
      if ~isempty(cfconds{ii,jj})
      % fill r with the corresponding condition, minus forecast..
      r=[r;cfconds{ii,jj}-fmat(ii,jj)];
      % .. and R with the corresponding orthogonalised IRFs entries
      % first increment R with a row of zeros of suitable dimension (N*n*Fperiods)
      R=[R;sparse(1,n*Fperiods)];
         % loop over periods up to the one on which there is the constraint
         for kk=1:ii
         R(end,(kk-1)*n+1:kk*n)=ortirfcell{ii-kk+1,ii}(jj,:);
         end
      % if there is no condition, don't do anything
      end
   end
end




% once the linear system is identified, draw a full vector of shocks from the Waggoner-Zha distribution
% realise the singular value decomposition of R as in (3.3.17) and obtain the corresponding matrices
% recover Q and K, the dimensions of the matrix Rtemp
[Q,K]=size(R);
% obtain the singular value decomposition
[U,S,V]=svd(full(R));
% obtain the required matrices
P=S(:,1:Q);
V1=V(:,1:Q);
V2=V(:,Q+1:end);
% draw the vector of constrained shocks from N(etabar,gammabar)
eta=V1/P*U'*r+V2*randn(K-Q,1);


