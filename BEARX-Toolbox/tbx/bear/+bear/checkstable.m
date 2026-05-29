function [stationary,eigmodulus]=checkstable(beta,n,p,k)



% function [stationary eigmodulus]=checkstable(beta,n,p,k)
% checks whether the estimated VAR model is covariance stationary, using the matrix F in (a.7.2)
% inputs:  - vector 'beta': vectorised form of the VAR coefficients (defined in 1.1.12)
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'p': number of lags included in the model (defined p 7 of technical guide)
%          - integer 'k': number of coefficients to estimate for each equation in the BVAR model (defined p 7 of technical guide)
% outputs: - integer 'stationary': 0-1 value indicating if the model is covariance stationary
%          - vector 'eigmodulus': modulus of the eigenvalues of the lag polynomial



% uses the matrix F in (a.7.2)

% recover the first matrix row of F
B=reshape(beta,k,n);
temp1=B(1:n*p,:)';

% recover the other two parts of F
temp2=eye(n*(p-1));
temp3=zeros(n*(p-1),n);

% obtain F
F=[temp1;temp2 temp3];


% then compute the absolute values of the eigenvalues of F and sort them by decreasing order
eigmodulus=sort(abs(eig(F)),'descend');

if eigmodulus(1,1)<0.999
stationary=1;
else
stationary=0;
end














