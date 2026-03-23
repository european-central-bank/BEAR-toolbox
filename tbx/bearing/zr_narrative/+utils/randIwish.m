function Sigma = randIwish(cholInvScale, df)

nVars   = size(cholInvScale, 1);
X       = randn(nVars, df);
A       = cholInvScale * X;
Sigma   = inv(A * A');

end