function [Ymat Xmat N n m p T k q h]=panel6prelim(data_endo,data_exo,const,lags)










% first compute N, the number of units, as the dimension of the data_endo matrix
N=size(data_endo,3);

% compute p, the number of lags in the model
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
k=N*n*p+m;

% determine q, the total number of VAR parameters for each unit
q=n*k;

% determine h, the total number of VAR parameters for the whole model
h=N*q;

% obtain Ymat and Xmat
temp=[];
% stack the matrices of endogenous variables to obtain a temporary matrix
for ii=1:N
temp=[temp data_endo(:,:,ii)];
end
% use the lagx function on this matrix
temp=lagx(temp,lags);

% set Ymat as the first Nn columns of the result
Ymat=temp(:,1:N*n);

% to build Xmat, take off the Nn initial columns of temp, and concatenate the exogenous
Xmat=[temp(:,N*n+1:end) data_exo];

% Define T, the number of periods of the model, as the number of rows of X
T=size(Xmat,1);







