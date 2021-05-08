function [arvar]=panelarloop(n,N,p,T,data_endo)








% obtain the (pooled) variance for each endogenous variables
% loop over endogenous variables
for ii=1:n

% initiate the data
Y=[];
X=[];

   % loop over Units
   for jj=1:N
   % lag the data
   temp=lagx(data_endo(:,ii,jj),p);
   % add a column of ones for the constant
   temp=[temp ones(T,1)];
   % increment Y from the first column
   Y=[Y;temp(:,1)];
   % increment X from the remaining columns
   X=[X;temp(:,2:end)];
   end

% obtain the OLS estimator
B=(X'*X)\(X'*Y);

% obtain the vector of residuals
eps=Y-X*B;

% obtain the variance of the series;
arvar(ii,1)=(1/(N*T-(p+1)))*(eps'*eps);

end