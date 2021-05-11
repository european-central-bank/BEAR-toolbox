function out=lagX(X,p)



% function out=lagX(X,p)
% returns lagged values of a matrix, sequentially lagging by 0,1,...,p periods and returning all the lags stacked in a single matrix
% inputs:  - matrix 'X': data matrix
%          - integer 'p': number of lags
% outputs: -matrix 'out': matrix of current and lagged series



% Compute the number of rows and columns of input matrix X, and save the values as r and c
[r,c]=size(X);

% start with the reformating of the original vectors
out(:,1:c)=X(p+1:r,:);

% treat each lag consecutively
for ii=1:p
out(:,c*ii+1:c*(ii+1))=X(p+1-ii:r-ii,:);
end