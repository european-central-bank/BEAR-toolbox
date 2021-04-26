function [prob]=mhprob3(cand,lambda,sbar,eps,Finv,n);


% compute the first part of the first exponential term
temp1=exp(-cand)-exp(-lambda);

% compute the second part of the first exponential term
% initiate the summation
temp2=0;
% loop over variables
   for jj=1:n
      % if jj=1 (first variable), the part finv*eps_i,t does not exist
      if jj==1
      temp3=(1/sbar(jj,1))*eps(1,1)^2;
      % if any other variable is considered, the term finv*eps_i,t must be taken into account
      else
      temp3=(1/sbar(jj,1))*(eps(1,1)+Finv{jj,1}'*eps(1:jj-1,1))^2;
      end
   % increment the summation
   temp2=temp2+temp3;
   end
% compute the (log of the) first exponential term
term1=-0.5*temp1*temp2;

% next compute the (log of the) second exponential term
term2=-(n/2)*(cand-lambda); 

% compute the sum of the two terms to obtain the log of the acceptance prob
% and exponentiate it to obtain the actual acceptance prob
prob=min(1,exp(term1+term2));
