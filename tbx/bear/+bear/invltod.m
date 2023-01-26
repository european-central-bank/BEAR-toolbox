function [invA]=invltod(A,n)






% computes the inverse of a n*n lower triangular matrix with ones on the main diagonal
% uses result (XXX) from Appendix (XXX)


% first obtain the B matrix from A
B=sparse(tril(A,-1));

% compute the summation term
summ=sparse(n,n);
prodt=speye(n);
for ii=1:n-1
prodt=prodt*B;
summ=summ+(-1)^ii*prodt;
end

% compute the inverse of A
invA=full(speye(n)+summ);



