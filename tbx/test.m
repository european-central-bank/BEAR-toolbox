

addpath ./sandbox -end

rng(0);
u = randn(100, 3);
Sigma = u' * u / 100;



P = chol(Sigma);
D = identifier.candidateFromFactorUnconstrained(P);

e = u / D;

D1 = D;
D1(1, :) = -D1(1, :);

e1 = u / D1;


* shock response - flip
* shock contribution - stay
* shock estimate - flip
* FEVD contribution - stay

