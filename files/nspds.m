function [A]=nspds2(A)



% first, check if the matrix is SPD by attempting to take the choleski factor
[~,test1]=chol(A,'lower');


% if it is SPD in the first place (test value=0), no need to apply any change
if test1<1
%Xf=A;  do nothing


% if it is not SPD, fix it
elseif test1>=1

% obtain the matrix Xf by applying theorem 2.1

% as a prelimineary, correct symmetry
A=tril(A)+tril(A,-1)';

% create B, as defined in theorem 2.1
A=(A+A')/2;
% produce the polar decomposition of B
% first, implement a singular value decomposition of B
[~,S,V]=svds(A);
% then recover the polar matrix H from the singular value decomposition formula: H=V*S*V'
%H=sparse(V*S*V');                      % this did not produce sparse H and generated out of memory errors
sp_V = sparse(V.*(V>1*10^(-14)));       % this will make sure V is sparse and clean small (useless) numbers
%H = sp_V*sparse(S)*sp_V';               % this will make sure H is sparse as well
% finally, recover Xf from the formula in theorem 2.1: Xf=(B+H)/2
%Xf=(B+H)/2;
A = (A+sp_V*sparse(S)*sp_V')/2;
% ensure symmetry

A=(A+A')/2;

% now the matrix should be symmetric positive definite: test again
[~,test2]=chol(A,'lower');

   % if the test is passed and Choleski factorisation was possible (test2=0), then Xf needs no further work;
   if test2<1
   
   % if the test is not passed, it must be because of some very small numerical disturbance
   % hence keep modifying Xf very slightly until it becomes SPD
   elseif test2>=1
      n=1;
      while test2>=1
%      mineig=min(eig(Xf))+0.0000000000000001;          % use eigs on sparse matrices
      mineig = eigs(A,1,0) + 0.0000000000000001;
      A=A+(-mineig*n.^2+eps(mineig))*speye(size(A));   % no longer sparse
      % test again
      [~,test2]=chol(A,'lower');
      n=n+1;
      end

   end

end
