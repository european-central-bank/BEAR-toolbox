function [prob]=mhprob(val,cand,term,n,N)






% obtain the first exponential term
exp1=exp(-0.5*(exp(-cand)-exp(-val))*term);
% obtain the second exponential term
exp2=exp(-0.5*N*n*(cand-val));

% obtain the acceptance probability
prob=min(1,exp1*exp2);




