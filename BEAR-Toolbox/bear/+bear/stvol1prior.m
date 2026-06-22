function [beta0 omega0 G I_o omega f0 upsilon0]=stvol1prior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,T,k,q,bex,blockexo,gamma,priorexo)













% start with beta0, defined in (1.3.4)
% it is a q*1 vector of zeros, save for the n coefficients of each variable on their own first lag 
beta0=zeros(q,1);
for ii=1:n
beta0((ii-1)*k+ii,1)=ar(ii,1);
end


% if a prior for the exogenous variables is selected put it in here:
for ii=1:n
    beta0(k*ii)=priorexo(ii,1);
end

% next compute omega0, the variance-covariance matrix of beta, defined in (1.3.8)
% set it first as a q*q matrix of zeros
omega0=zeros(q,q);

% set the variance on coefficients related to own lags, using (1.3.5)
for ii=1:n
   for jj=1:p
   omega0((ii-1)*k+(jj-1)*n+ii,(ii-1)*k+(jj-1)*n+ii)=(lambda1/jj^lambda3)^2;
   end
end


%  set variance for coefficients on cross lags, using (1.3.6)
for ii=1:n
   for jj=1:p
      for kk=1:n
      if kk==ii
      else
      omega0((ii-1)*k+(jj-1)*n+kk,(ii-1)*k+(jj-1)*n+kk)=(arvar(ii,1)/arvar(kk,1))*(((lambda1*lambda2)/(jj^lambda3))^2);
      end
      end
   end
end


% finally set the variance for exogenous variables, using (1.3.7)
for ii=1:n 
   for jj=1:m
   omega0(ii*k-m+jj,ii*k-m+jj)=arvar(ii,1)*((lambda1*lambda4(1,1))^2);
   end
end


% if block exogeneity has been selected, implement it, according to (1.7.4)
if bex==1
   for ii=1:n
      for jj=1:n
         if blockexo(ii,jj)==1
            for kk=1:p
            omega0((jj-1)*k+(kk-1)*n+ii,(jj-1)*k+(kk-1)*n+ii)=omega0((jj-1)*k+(kk-1)*n+ii,(jj-1)*k+(kk-1)*n+ii)*lambda5^2;
            end
         else
         end
      end
   end
% if block exogeneity has not been selected, don't do anything 
else
end


% compute the G matrix, defined in XXX
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







