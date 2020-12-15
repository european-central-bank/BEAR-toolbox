function [result coeff] = RS_PF_OLS_Wald(y,x1,x2)
% Calculates OLS Wald-Test 
% H0: beta=0 in the model
% y = x1*beta+x2*gamma+eps with HAC consistent var-covar
% If want to test all coefficients, simply use (y,x1) and do not include x2

q = 0;
n = size(y,1); 
p = size(x1,2);  

if nargin>2; 
    q = size(x2,2);
    x = [x1,x2]; 
    R = [eye(p),zeros(p,q)];  
else
    x = x1; 
    R = eye(p); 
end;

coeff = ((inv(x'*x))*(x'*y));
nlag  = round(n^(1/4));

% Compute Newey-West adjusted heteroscedastic-serial consistent 
% least-squares regression
nwresult   = RS_PF_nwest(y,x,nlag); 
varbetahat = nwresult.vcv;        

result = (R*coeff)'/(R*varbetahat*R')*R*coeff;