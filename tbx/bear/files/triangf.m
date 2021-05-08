function [D gamma]=triangf(X)



% function [D gamma]=triangf(X)
% returns the triangular factorisation for a symmetric positive definite matrix X
% that is, returns D and gamma such that X=D*gamma*D'
% inputs:  -matrix 'X': the input matrix; has to be symmetric and positive definite
% outputs: -matrix 'D': the lower triangular output matrix : has ones on the main diagonal
%          -matrix 'gamma': the diagonal output matrix


% this function implements the procedure defined p53


temp=chol(nspd(X),'lower');
n=size(X,1);
D=zeros(n,n);
gamma=zeros(n,n);

for ii=1:n
D(:,ii)=temp(:,ii)/temp(ii,ii);
gamma(ii,ii)=temp(ii,ii)^2;
end











