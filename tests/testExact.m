
n = size(Sigma,1);

% Can get factors of the form Sigma==T'*T using the eigenvalue
% decomposition of a symmetric matrix, so long as the matrix
% is positive semi-definite.
[U,D] = eig(full((Sigma+Sigma')/2));

% Pick eigenvector direction so max abs coordinate is positive
[~,maxind] = max(abs(U),[],1);
negloc = (U(maxind + (0:n:(n-1)*n)) < 0);
U(:,negloc) = -U(:,negloc);

D = diag(D);

T = diag(sqrt(D)) * U(:,t)';
T = T';

