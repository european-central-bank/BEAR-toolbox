function [beta0 omega0]=ndprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k,q,bex,blockexo,priorexo)



% function [beta0 omega0]=ndprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k,q,bex,blockexo)
% returns prior values from hyperparameters, for the normal-diffuse prior
% inputs:  - scalar 'ar': prior value of the autoregressive coefficient on own first lag (defined p 15 of technical guide)
%          - vector 'arvar': residual variance of individual AR models estimated for each endogenous variable
%          - scalar 'lambda1': overall tightness hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda2': cross-variable weighting hyperparameter(defined p 16 of technical guide)
%          - scalar 'lambda3': lag decay hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda4': exogenous variable tightness hyperparameter (defined p 17 of technical guide)
%          - scalar 'lambda5': block exogeneity shrinkage hyperparameter (defined p 32 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'bex': 0-1 value to determine if block exogeneity is applied to the model
%          - matrix 'blockexo': matrix indicating the variables on which block exogeneity must be applied
% outputs: - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'omega0': prior covariance matrix for the VAR coefficients (defined in 1.3.8)



% start with beta0, defined in (1.3.4)
beta0=zeros(q,1);
for ii=1:n
beta0((ii-1)*k+ii,1)=ar(ii,1);
end

% if a prior for the exogenous variables is selected put it in here:
for ii=1:n
    for jj=1:m
    beta0(k*ii-m+jj)=priorexo(ii,jj);
    end
end


% next compute omega0, the variance-covariance matrix of beta, defined in (1.3.8)
% set it first as a q*q matrix of zeros
omega0=zeros(q,q);

% set variance for coefficients on own lags, using (1.3.5)
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
   omega0(ii*k-m+jj,ii*k-m+jj)=arvar(ii,1)*((lambda1*lambda4(ii,jj))^2);
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

