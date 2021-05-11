function [omegab]=panel4prior(N,n,m,p,T,k,data_endo,q,lambda3,lambda2,lambda4)







% lambda4 is no vector here
lambda4=lambda4(1,1);



% obtain omegab, which is basically a Minnesota covariance matrix without lambda1


% first obtain the residual variance of individual (pooled) autoregressive models
[arvar]=panelarloop(n,N,p,T,data_endo);

% next compute omega0, the variance-covariance matrix of beta, defined in (1.3.8)
% set it first as a q*q matrix of zeros
omegab=zeros(q,q);

% set the variance on coefficients related to own lags, using (1.3.5)
for ii=1:n
   for jj=1:p
   omegab((ii-1)*k+(jj-1)*n+ii,(ii-1)*k+(jj-1)*n+ii)=(1/(jj^lambda3))^2;
   end
end

%  set variance for coefficients on cross lags, using (1.3.6)
for ii=1:n
   for jj=1:p
      for kk=1:n
      if kk==ii
      else
      omegab((ii-1)*k+(jj-1)*n+kk,(ii-1)*k+(jj-1)*n+kk)=(arvar(ii,1)/arvar(kk,1))*((lambda2/(jj^lambda3))^2);
      end
      end
   end
end

% finally set the variance for exogenous variables, using (1.3.7)
for ii=1:n 
   for jj=1:m
   omegab(ii*k-m+jj,ii*k-m+jj)=arvar(ii,1)*(lambda4^2);
   end
end

