function [B0 beta0 phi0 S0 alpha0]=nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,priorexo)



% function [B0 beta0 phi0 S0 alpha0]=nwprior(ar,arvar,lambda1,lambda3,lambda4,n,m,p,k,q,prior,bex)
% returns prior values from hyperparameters, for the normal-Wishart prior
% inputs:  - scalar 'ar': prior value of the autoregressive coefficient on own first lag (defined p 15 of technical guide)
%          - vector 'arvar': residual variance of individual AR models estimated for each endogenous variable
%          - scalar 'lambda1': overall tightness hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda2': cross-variable weighting hyperparameter(defined p 16 of technical guide)
%          - scalar 'lambda3': lag decay hyperparameter (defined p 16 of technical guide)
%          - scalar 'lambda4': exogenous variable tightness hyperparameter (defined p 17 of technical guide)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)
%          - integer 'prior': value to determine which prior applies to the model
% outputs: - matrix 'B0': the non-vectorised form of beta0
%          - vector 'beta0': vector of prior values for beta (defined in 1.3.4)
%          - matrix 'phi0': prior covariance matrix for the VAR coefficients in the case of a normal-Wishart prior (defined in 1.4.7)
%          - matrix 'S0': prior scale matrix for sigma (defined in 1.4.11)
%          - integer 'alpha0': prior degrees of freedom for sigma (defined in 1.4.11)


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
% unvectorize (reshape) the vector to obtain the matrix B0
B0=reshape(beta0,k,n);

% next compute phi0, the variance-covariance matrix of beta, defined in (1.4.7)

% set first phi0 as a k*k matrix of zeros
phi0=zeros(k,k);

% set the variance for coefficients on lagged values, using (1.4.5)
for ii=1:n
   for jj=1:p
   phi0((jj-1)*n+ii,(jj-1)*n+ii)=(1/arvar(ii,1))*(lambda1/jj^lambda3)^2;
   end
end

% set the variance for exogenous variables, using (1.4.6)
for ii=1:m
phi0(k-m+ii,k-m+ii)=(lambda1*lambda4(1,ii))^2;
end


% now compute alpha0 from (1.4.12)
alpha0=n+2;


% and finally compute S0, depending on which choice has been made for the prior ((1.4.13) or identity)
if prior==21
S0=(alpha0-n-1)*diag(arvar);
elseif prior==22
S0=eye(n);
else
end



