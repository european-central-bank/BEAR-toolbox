function draw=matrixtdraw(B,S,phi,alpha,k,n)

% function draw=matrixtdraw(B,S,phi,alpha,k,n)
% creates a k*n random draw from a matrix-variate student distribution with location (mean) B, scale matrices S and phi, and degrees of freedom alpha.
% inputs:  - matrix 'B': the k*n location matrix
%          - matrix 'S': the n*n scale matrix; must be symmetric positive definite
%          - matrix 'phi': the k*k scale matrix; must be symmetric positive definite
%          - integer 'alpha': the degrees of freedom of the matrix student distribution
%          - integer 'k': the row dimension of the matrix distribution
%          - integer 'n': the column dimension of the matrix distribution
% outputs: - matrix 'draw': the k*n random draw from the matrix student distribution


% this funtion uses the matrix-t algorithm provided in Karlsson (2012): see algorithm 22

% first draw a n*n matrix sigma from IW(S,alpha)
sigma=iwdraw(S,alpha);

% compute the lower Choleski factor of sigma
C=chol(nspd(sigma),'lower');

% compute the lower choleski factor of phi
P=chol(nspd(phi),'lower');

% take a kn*1 random draw from a multivariate standard normal distribution, and redimension it to obtain a k*n matrix-variate normal
w=randn(k*n,1);
W=reshape(w,k,n);

% obtain the random draw from the matrix-variate student by adding the location matrix and multiplying by both scale matrices
draw=B+P*W*C';