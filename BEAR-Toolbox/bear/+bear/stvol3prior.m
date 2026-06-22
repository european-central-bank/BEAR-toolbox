function [B0 phi0 G I_o omega f0 upsilon0]=stvol3prior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,T,k,q,gamma,priorexo)














% obtain B0
% start first by obtaining beta0
beta0=zeros(q,1);
for ii=1:n
beta0((ii-1)*k+ii,1)=ar(ii,1);
end


% if a prior for the exogenous variables is selected put it in here:
for ii=1:n
    beta0(k*ii)=priorexo(ii,1);
end

% reshape the vector to obtain the matrix B0
B0=reshape(beta0,k,n);


% next compute phi0
% set first phi0 as a k*k matrix of zeros
phi0=zeros(k,k);
% set the variance for coefficients on lagged values
for ii=1:n
   for jj=1:p
   phi0((jj-1)*n+ii,(jj-1)*n+ii)=(1/arvar(ii,1))*(lambda1/jj^lambda3)^2;
   end
end
% set the variance for exogenous variables
for ii=1:m
phi0(k-m+ii,k-m+ii)=(lambda1*lambda4(ii))^2;
end


% compute the G matrix
G=speye(T)-sparse(diag(gamma*ones(T-1,1),-1));
% set the value for omega
omega=10000;
% compute I_omega
I_o=sparse(diag([1/omega;ones(T-1,1)]));


% compute the series of f0 vector and upsilon0 matrices
f0=cell(n,1);
upsilon0=cell(n,1);
for ii=2:n
f0{ii,1}=zeros(ii-1,1);
upsilon0{ii,1}=10000*eye(ii-1);
end







