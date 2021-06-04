function [prob]=mhprob2(jj,cand,lambda,sbar,eps,finv);

%lambda=logHvarsOld(kk,jj)
%sbar=scaling(jj,1)
%eps=epst(:,1,kk-p)
%finv = Abelowdiag{jj,1}
% compute the first part of the first exponential term
temp1=exp(-cand)-exp(-lambda);

% compute the second part of the first exponential term
% if jj=1 (first variable), the part finv*eps_i,t does not exist
if jj==1
temp2=(1/sbar)*eps(1,1)^2;
% if any other variable is considered, the term finv*eps_i,t must be taken into account
else
temp2=(1/sbar)*(eps(jj,1)+finv'*eps(1:jj-1,1))^2;
%temp2=(1/sbar)*(eps(1,1)+finv'*eps(1:jj-1,1))^2;
end

% compute the (log of the) first exponential term
term1=-0.5*temp1*temp2;

% next compute the (log of the) second exponential term
term2=-0.5*(cand-lambda); 

% compute the sum of the two terms to obtain the log of the acceptance prob
% and exponentiate it to obtain the actual acceptance prob
prob=min(1,exp(term1+term2));
