function [Xi Xibar Xbar Yi yi y N n m p T k q h]=panel4prelim(data_endo,data_exo,const,lags)







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
k=n*p+m;

% determine q, the total number of VAR parameters for each unit
q=n*k;

% determine h, the total number of VAR parameters for the whole model
h=N*q;

% obtain Yi and Xi for each unit: loop over units
for ii=1:N

% use the lagx function on the data matrix
temp=lagx(data_endo(:,:,ii),lags);

% set Yi as the first n columns of the result
Yi(:,:,ii)=temp(:,1:n);

% to build Xi, take off the n initial columns of temp, and concatenate the exogenous
Xi(:,:,ii)=[temp(:,n+1:end) data_exo];

end

% Define T, the number of periods of the model, as the number of rows of X
T=size(Xi,1);

% then define the vectors yi and the matrices Xibar
% loop again over units
Xibar={};
for ii=1:N

yi(:,:,ii)=vec(Yi(:,:,ii));

Xibar{ii,1}=kron(speye(n),Xi(:,:,ii));

end

% eventually define ybar and Xbar
y=vec(yi);

Xbar=sparse([]);
for ii=1:N
Xbar=[Xbar;repmat(speye(n*T,q),1,ii-1) Xibar{ii,1} repmat(speye(n*T,q),1,N-ii)];
end
















