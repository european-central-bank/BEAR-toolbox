function [Bhat,betahat,sigmahat,X,Xbar,Y,y,EPS,eps,n,m,p,T,k,q]=olsvar(data_endo,data_exo,const,lags)



% function [Bhat betahat sigmahat X Xbar Y y EPS eps n m p T k q]=olsvar(data_endo,data_exo,const,lags)
% estimates the coefficients of an OLS VAR model, along with other realted values
% inputs:  - matrix 'data_endo': matrix of endogenous data used for model estimation 
%          - matrix 'data_exo': matrix of exogenous data used for model estimation
%          - integer 'const': 0-1 value to determine if a constant is included in the model
%          - integer 'lags': number of lags included in the model
% outputs: - matrix 'Bhat': OLS VAR coefficients, in non vectorised form (defined in 1.1.9) 
%          - vector 'betahat': OLS VAR coefficients in vectorised form (defined in 1.1.15)
%          - matrix 'sigmahat': OLS VAR variance-covariance matrix of residuals (defined in 1.1.10)
%          - matrix 'X': matrix of regressors for the VAR model (defined in 1.1.8)
%          - matrix 'Xbar': Kronecker matrix of regressors for the VAR model (defined in 1.1.12)
%          - matrix 'Y': matrix of regressands for the VAR model (defined in 1.1.8)
%          - vector 'y': vectorised regressands for the VAR model (defined in 1.1.12)
%          - matrix 'EPS': matrix of VAR residuals (defined in 1.1.7)
%          - vector 'eps': vector of VAR residuals (defined in 1.1.12)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'm': number of exogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
%          - integer 'q': total number of coefficients to estimate for the BVAR model (defined p 7 of technical guide)





% first compute p, the number of lags in the model
p=lags;

% then compute n, the number of endogenous variables in the model; it is simply the number of columns in the matrix 'data_endo'
n=size(data_endo,2);

% if the constant has been selected, augment the matrix of exogenous with a column of ones (number of rows equal to number of rows in data_endo)
if const==1
data_exo=[ones(size(data_endo,1),1) data_exo];
% if no constant was included, do nothing
else
end

% compute m, the number of exogenous variables in the model
% if data_exo is empty, set m=0
if isempty(data_exo)==1
m=0;
% if data_exo is not empty, count the number of exogenous variables that will be included in the model
else
m=size(data_exo,2);
% Also, trim a number initial rows equal to the number of lags, as they will be suppressed from the endogenous as well to create initial conditions
data_exo=data_exo(p+1:end,:);
end

% determine k, the number of parameters to estimate in each equation; it is equal to np+m
k=n*p+m;

% determine q, the total number of VAR parameters to estimate; it is equal to n*k
q=n*k;

% obtain X as defined in (1.1.8)
% to do so, use the lagx function on the data matrix
% this will basically return the matrix X without the exogenous variables, but with n additional columns of current period data
temp=lagx(data_endo,lags);
% to build X, take off the n initial columns of current data, and concatenate the exogenous
X=[temp(:,n+1:end) data_exo];

% Define T, the number of periods of the model, as the number of rows of X
T=size(X,1);

% then compute Xbar as defined in equation (1.1.13)
Xbar=kron(eye(n),X);

% save the n first columns of temp as Y, as defined in (1.1.8)
Y=temp(:,1:n);

% define y as in equation (1.1.13)
y=Y(:);

% obtain the OLS estimate for B from (1.1.9)
Bhat=(X'*X)\(X'*Y);

% obtain betahat, defined in (1.1.15)
% obtain it by vectorising Bhat
betahat=Bhat(:);

% compute the residuals EPS from (1.1.7)
EPS=Y-X*Bhat;

% compute the OLS vectorised residuals eps by vectorising EPS
eps=EPS(:);

% estimate the variance-covariance matrix sigmahat from (1.1.10)
sigmahat=(1/(T-k))*(EPS'*EPS);


