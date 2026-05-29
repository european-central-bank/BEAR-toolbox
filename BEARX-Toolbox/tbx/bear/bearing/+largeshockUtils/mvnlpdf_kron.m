function lpdf = mvnlpdf_kron(x, P1, P2)

n1 = size(P1, 1);
n2 = size(P2, 1);

lpdf  = -n1*n2/2 * log(2*pi) - n2 * sum(log(diag(P1))) - n1 * sum(log(diag(P2)));

optsLT.LT = true;
optsUT.UT = true;

tmp = x;
tmp = linsolve(P2,  tmp,  optsLT);
tmp = linsolve(P2', tmp,  optsUT);
tmp = linsolve(P1,  tmp', optsLT);
tmp = linsolve(P1', tmp,  optsUT)';

lpdf  = lpdf - 0.5 * x(:)' * tmp(:);

end