function [Y, X, Z, n, m, p, T, k1, k3, q1, q2, q3,X1,Y1,data_exo]=TVEmaprelim(data_endo,data_exo,const,lags,regimeperiods,names)



% function [Y X Z n m p T k1 k3 q1 q2 q3]=maprelim(data_endo,data_exo,const,lags)
% creates the preliminary values necessary for all the subsequent computations
% inputs:  - matrix 'data_endo': the matrix storing the endogenous time series data used to estimate the model
%          - matrix 'data_exo': the matrix storing the exogenous time series data used to estimate the model
%          - integer 'const': 0-1 value determining whether a constant term should be included in the model
%          - integer 'lags': the number of lags to include in the model
% outputs: - matrix 'Y': the matrix of endogenous variables, defined in (3.5.10)
%          - matrix 'X': the matrix of endogenous regressors, defined in (3.5.10)
%          - matrix 'Z': the matrix of exogenous regressors, defined in (3.5.10)
%          - integer 'n': the number of endogenous variables in the model
%          - integer 'm': the number of exogenous variables in the model
%          - integer 'p': the number of lags in the model
%          - integer 'T': the sample size, i.e. the number of time periods used to estimate the model
%          - integer 'k1': the number of coefficients related to the endogenous variables for each equation in the model
%          - integer 'k3': the number of coefficients related to the exogenous variables for each equation, in the reformulated model (3.5.5)
%          - integer 'q1': the total number of VAR coefficients related to the endogenous variables
%          - integer 'q2': the total number of VAR coefficients related to the exogenous variables
%          - integer 'q3': the total number of VAR coefficients related to the exogenous variables, in the reformulated model (3.5.5)



% first compute p, the number of lags in the model, defined p77
p=lags;

% then compute n, the number of endogenous variables in the model; it is simply the number of columns in the matrix 'data_endo'
n=size(data_endo,2);


% augment the matrix of exogenous with a column of ones to account for the constant
%data_exo=[ones(size(data_endo,1),1) data_exo];
%alternative data exo

if isempty(regimeperiods)
    data_exo=[ones(size(data_endo,1),1)];
else
data_exo=[ones(size(data_endo,1),1) zeros(size(data_endo,1),1)];
data_exo(find(strcmp(names(2:end,1),regimeperiods(1))):find(strcmp(names(2:end,1),regimeperiods(2))),2)=1;
data_exo(find(strcmp(names(2:end,1),regimeperiods(1))):find(strcmp(names(2:end,1),regimeperiods(2))),1)=0;
end

% then compute m, the number of exogenous variables in the model, defined p77
% if data_exo is empty, set m=0
m=size(data_exo,2);

%%%%% Also, trim a number initial rows equal to the number of lags, as they will be suppressed from the endogenous as well to create initial conditions
data_exo1=data_exo(p+1:end,:);

% estimate k1, the number of parameters related to endogenous variables in each equation, defined p77
k1=n*p;

% estimate q1, the total number of parameters related to endogenous variables, defined p77
q1=n*k1;

% estimate q2, the total number of parameters related to exogenous variables, defined p77
q2=n*m;

% estimate k3, the number of parameters related to exogenous variables in each equation of the modified system, defined p78
k3=m*(p+1);

% estimate q3, the total number of parameters related to endogenous variables in the modified system, defined p78
q3=n*k3;

% obtain the matrices Y and X, defined in (3.6.10)
% to do so, use the lagx function on the data matrix
temp=lagx(data_endo,lags);

% to build X, take off the n initial columns of current data
X=temp(:,n+1:end);

%%%%% to build X, take off the n initial columns of current data, and concatenate the exogenous
X1=[temp(:,n+1:end) data_exo1];

% save the n first columns of temp as Y
Y=temp(:,1:n);

%%%%% save the n first columns of temp as Y
Y1=temp(:,1:n);

% obtain the matrix Z, defined in (3.6.10)
temp=lagx(data_exo,lags);
temp(:,m+1:end)=-temp(:,m+1:end);
Z=temp;


% Define T, the number of periods of the model, as the number of rows of Y
T=size(Y,1);

data_exo=Z;

% obtain eventually y, Xbar and Zbar, as defined in (XXX)
% % % y=Y(:);
% % % Xbar=kron(eye(n),X);
% % % Zbar=kron(eye(n),Z);





