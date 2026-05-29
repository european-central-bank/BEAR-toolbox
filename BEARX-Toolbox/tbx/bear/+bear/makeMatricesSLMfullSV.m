function [KFSmatrices] = makeMatricesSLMfullSV(dataValues,p)
%% Purpose 
%  This function calculates the required matrices for the Kalman Filter for the SLM full SV model. 
% The model is Y 

%% Initialize 
Ppsi=dataValues.Ppsi;
[ns,n]=size(Ppsi);

%% Z: coefficients of measurment equation
Ztemp=zeros(ns+n,n*(p+1));
Ztemp(ns+1:end,1:2*n)=[eye(n) eye(n)];
Ztemp(1:ns,1:n)= Ppsi;
KFSmatrices.Zmatrix=Ztemp;
 
%% R: for variance covariance in transition equation
KFSmatrices.R=[eye(2*n);zeros(n*(p-1),2*n)];

%% L: for variance covariance in measurement equation
KFSmatrices.L=[eye(ns);zeros(n,ns)];

%% Tmatrix: coefficients in transition equation 
TmatrixTemp=zeros(n*(p+1),n*(p+1));
TmatrixTemp(1:n,1:n) = eye(n);
%TmatrixTemp(n+1:2*n,n+1:end) = Bhat';
TmatrixTemp(2*n+1:end,n+1:end-n) = eye(n*(p-1));

KFSmatrices.Tmatrix=TmatrixTemp; 
 

end

