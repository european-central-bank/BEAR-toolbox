function [logml]=nwmlikgrid(X,n,k,phi0,S0,Sbar,alphabar)












% compute the first determinant part
% create the square root matrix of phi0
% because phi0 is diagonal, this is simply the square root of the diagonal terms of phi0
Fphi=spdiags(diag(phi0).^0.5,0,k,k);
% compute the product
product=Fphi'*X'*X*Fphi;
% compute the eigenvalues of the product
eigenvalues=eig(product);
% now compute the full determinant term
temp1=(-n/2)*log(prod(diag(eye(k)+diag(eigenvalues))));

% compute the second determinant part
% create the square root matrix of inv(S0)
invS0=spdiags(1./diag(S0),0,n,n);
Fs=spdiags(diag(invS0).^0.5,0,n,n);
% compute the summation
summ=Fs'*(Sbar-S0)*Fs;
% compute the eigenvalues of the summation
eigenvalues=eig(summ);
% now compute the full determinant term
temp2=(-alphabar/2)*log(prod(diag(eye(n)+diag(eigenvalues))));

% compute the marginal likelihood
logml=real(temp1+temp2);





