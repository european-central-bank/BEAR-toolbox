function [B, Sigma] = randNIW(meanB, cholInvPrecB, cholInvScaleSigma, dfSigma)

nPars   = numel(meanB);
nVars   = size(cholInvScaleSigma, 1);
nParsEq = nPars / nVars;   

Sigma = utils.randIwish(cholInvScaleSigma, dfSigma);

cholCovVecB = kron(chol(Sigma, "lower"), cholInvPrecB);

X = randn(nPars, 1);
vecB = meanB(:) + cholCovVecB * X;

B = reshape(vecB, nParsEq, nVars);

end