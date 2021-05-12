function [logml]=mmlikgrid(X,y,n,T,q,sigma,beta0,omega0,betabar,omegabar)








% compute the log determinant part
% create the square root matrix of omega0
% because omega0 is diagonal, this is simply the square root of the diagonal terms of omega0
Fomega=spdiags(diag(omega0).^0.5,0,q,q);
% compute the inverse of sigma
C=chol(nspd(sigma));
invC=C\speye(n);
invsigma=invC*invC';
% compute the product
product=Fomega'*kron(invsigma,X'*X)*Fomega;
% compute the eigenvalues of the product
eigenvalues=eig(product);
% now compute the full determinant term
temp1=(-1/2)*log(prod(diag(eye(q)+diag(eigenvalues))));

% compute the final term
% first compute the inverse of omega0, which is a diagonal matrix (hence simply invert element wise the diagonal terms)
invomega0=spdiags(1./diag(omega0),0,q,q);
% now compute the whole matrix sum
summ=beta0'*invomega0*beta0-betabar'/omegabar*betabar+y'*kron(invsigma,speye(T))*y;
% finally, compute the whole exponential term
temp2=-0.5*summ;

% compute the marginal likelihood
logml=real(temp1+temp2);









