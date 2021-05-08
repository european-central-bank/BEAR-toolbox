function [X Xmat Y Ymat N n m p T k q]=panel2prelim(data_endo,data_exo,const,lags,Units)











% first compute p, the number of lags in the model
p=lags;

% compute the number of units; it is the number of elements in the cell called Units
N=size(Units,1);

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

% obtain X and Y

% initiate the preliminary matrices
Xmat=[];
Ymat=[];
% loop over units
for ii=1:N
% first use the lagx function on the data matrix
% this will basically return the matrix X without the exogenous variables, but with n additional columns of current period data
temp=lagx(data_endo(:,:,ii),lags);
% then take off the n initial columns of current data, and concatenate the exogenous
% record this as the corresponding page of X data
Xmat(:,:,ii)=[temp(:,n+1:end) data_exo];
% save the n first columns of temp as Y
Ymat(:,:,ii)=temp(:,1:n);
end

% Define T, the number of periods of the model, as the number of rows of Xmat
T=size(Xmat,1);

% now obtain X and Y
X=[];
Y=[];
% loop over time periods
for ii=1:T
   %loop over units
   for jj=1:N
   X=[X;Xmat(ii,:,jj)];
   Y=[Y;Ymat(ii,:,jj)];
   end
end

