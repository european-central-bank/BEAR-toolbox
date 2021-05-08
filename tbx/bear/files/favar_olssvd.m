% Computes the OLS estimator (Handles system of equations)
% Jean Boivin
% 11/18/01

% y = T x k matrix -- LHS of the VAR
% ly = T x k*p+1 matrix -- constant + lags of y
function b=favar_olssvd(y,ly)

[vl,d,vr]=svd(ly,0);
d=1./diag(d);
b=(vr.*repmat(d',size(vr,1),1))*(vl'*y);

