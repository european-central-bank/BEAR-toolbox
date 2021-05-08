function [beta0 omega0 psi0 lambda0 r]=maprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k1,q1,q2,bex,blockexo,Fpconfint,Fpconfint2,chvar,regimeperiods,Dmatrix,equilibrium,data_endo,priorf)



% function [beta0 omega0 psi0 lambda0 r]=maprior(ar,arvar,lambda1,lambda2,lambda3,lambda4,lambda5,n,m,p,k1,q1,q2,bex,blockexo,Fpconfint)
% takes parameter and hyperparameter values and returns values for the mean-adjusted VAR prior
% inputs:  - integer 'ar': Minnesota auto-regressive coefficient of each variable on its own first lag
%          - vector 'arvar': the vector recording the residual variance for each AR model
%          - scalar 'lambda1': own-lag specific variance parameter, defined in (1.3.5)
%          - scalar 'lambda2': cross-variable variance parameter, defined in (1.3.6)
%          - scalar 'lambda3': scaling coefficient controlling the shrinkage on different lags, defined in (1.3.6)
%          - scalar 'lambda4': variance parameter on exogenous variables, defined in (1.3.7)
%          - scalar 'lambda5': variance parameter on block exogenous variables, defined in (1.7.4)
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'p': the number of lags in the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
%          - integer 'q1': the total number of VAR coefficients related to the endogenous variables
%          - integer 'q2': the total number of VAR coefficients related to the exogenous variables
%          - integer 'bex': 0-1 value determining whether block exogeneity should be implemented by the code
%          - matrix 'blockexo': the matrix determining which variable is exogenous to which other variable
%          - cell 'Fpconfint': the cell containing the prior confidence intervals for the coefficients on exogenous data
%          - 
% outputs: - vector 'beta0': the vector containing the mean of the prior distribution for beta, defined in (3.5.17)
%          - matrix 'omega0': the variance-covariance matrix for the prior distribution of beta, defined in (3.5.17)
%          - vector 'psi0': the vector containing the mean of the prior distribution for psi, defined in (3.5.19)
%          - matrix 'lambda0': the variance-covariance matrix for the prior distribution of psi, defined in (3.5.19)
%          - r




% first compute the prior elements for the vector beta, defined in (3.6.17)
% start with beta0
% it is a q1*1 vector of zeros, save for the n coefficients of each variable on their own first lag
beta0=zeros(q1,1);
for ii=1:n
beta0((ii-1)*k1+ii,1)=ar(ii,1);
end



% next compute omega0, the variance-covariance matrix of beta, defined in (3.6.17)
% set it first as a q1*q1 matrix of zeros
omega0=zeros(q1,q1);

% set variance for coefficients on own lags
for ii=1:n
   for jj=1:p
   omega0((ii-1)*k1+(jj-1)*n+ii,(ii-1)*k1+(jj-1)*n+ii)=(lambda1/jj^lambda3)^2;
   end
end

%  set variance for coefficients on cross lags
for ii=1:n
   for jj=1:p
      for kk=1:n
      if kk==ii
      else
      omega0((ii-1)*k1+(jj-1)*n+kk,(ii-1)*k1+(jj-1)*n+kk)=(arvar(ii,1)/arvar(kk,1))*(((lambda1*lambda2)/(jj^lambda3))^2);
      end
      end
   end
end


% if block exogeneity has been selected, implement it 
if bex==1
   for ii=1:n
      for jj=1:n
         if blockexo(ii,jj)==1
            for kk=1:p
            omega0((jj-1)*k1+(kk-1)*n+ii,(jj-1)*k1+(kk-1)*n+ii)=omega0((jj-1)*k1+(kk-1)*n+ii,(jj-1)*k1+(kk-1)*n+ii)*lambda5^2;
            end
         else
         end
      end
   end
% if block exogeneity has not been selected, don't do anything 
else
end


% then compute the prior elements for the vector psi, defined in (3.6.19)
% start with psi0
% it is a q2*1 vector obtained from the specified confidence interval: simply take the center of the interval
f=priorf; %
%if isnan(Fpconfint{1})==1;
r=chvar*size(regimeperiods,1)+1;
[psi0,lambda0] = TVEcreatePriorDeterministic(equilibrium,r,data_endo,Dmatrix,f,Fpconfint,Fpconfint2);
end