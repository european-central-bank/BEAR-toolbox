function [draw]=iwdraw(S,alpha)



% function [draw]=iwdraw(S,alpha)
% creates a random draw from an inverse Wishart distribution with scale matrix S and degrees of freedom alpha
% inputs:  - matrix 'S': scale matrix for sigma
%          - integer 'alpha': degrees of freedom for sigma
% outputs: - matrix 'draw': random draw from the inverse Wishart distribution




% first obtain a stabilised lower Cholesky factor of S
C=chol(nspd(S),'Lower');

% draw the matrix Z of alpha multivariate standard normal vectors
Z=randn(alpha,size(S,1));

% obtain the draw
draw=(C/(Z'*Z))*C';


