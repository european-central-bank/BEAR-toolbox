
function D = candidateFromFactorUnconstrained(P, randFunc)

    if nargin < 3
        randFunc = @randn;
    end

    X = randFunc(size(P));
    [Q, R] = qr(X);
    Q = Q * diag(diag(sign(R)));
    D = Q * P;

end%

