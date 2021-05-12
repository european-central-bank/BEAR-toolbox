function draw=matrixndraw(M,sigma,phi,k,n)





% compute the lower Choleski factor of sigma
C=chol(nspd(sigma),'lower');

% compute the lower choleski factor of phi
P=chol(nspd(phi),'lower');

% take a kn*1 random draw from a multivariate standard normal distribution, and redimension it to obtain a k*n matrix-variate normal
W=randn(k,n);

% obtain the random draw from the matrix-variate student by adding the location matrix and multiplying by both scale matrices
draw=M+P*W*C';