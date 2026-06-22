function response = impulsdtrf(B,smat,nstep)

%function response=impulsdtrf(B,smat,nstep)
% Assumes the same model as in rfvar, except here only the By part is used.
% smat is a square matrix of initial shock vectors. To produce "orthogonalized
% impulse responses" it should have the property that smat'*smat=sigma, where sigma
% is the Var(u(t)) matrix and u(t) is the residual vector. One way to get such a smat
% is to set smat=chol(sigma). To get the smat corresponding to a different ordering,
% use smat = P' * chol(P * Sigma * P') * P, where P is a permutation matrix. (Or equivalently,
% smat = chol(Sigma(ndx,ndx))(indx,indx), where ndx is a permutation vector and indx is its
% inverse. E.g. ndx = [3 2 1], indx = [3,2,1], or ndx = [2, 3, 1], indx = [3,1,2]. In general
% ndx(indx) = 1:length(ndx).
% B is a neq x nvar x nlags matrix. neq=nvar, of course, but the first index runs over
% equations. In response, the first index runs over variables, the second over
% shocks (in effect, equations), the third over time.
% Code written by Christopher Sims. This version 6/15/03.

[neq,nvar,nlag]=size(B);
response=zeros(neq,nvar,nstep);
response(:,:,1)=smat';

for it=2:nstep
    for ilag=1:min(nlag,it-1)
        response(:,:,it) = response(:,:,it) + B(:,:,ilag)*response(:,:,it-ilag);
    end
end