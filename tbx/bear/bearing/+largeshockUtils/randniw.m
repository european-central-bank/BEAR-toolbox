function [B, Sigma] = randniw(meanB, cholCovB, cholInvScaleSigma, dfSigma)

nPars   = numel(meanB);
nVars   = size(cholInvScaleSigma, 1);
nParsEq = nPars / nVars;   

Sigma = distr.randiwish(cholInvScaleSigma, dfSigma);
cholSigmaTr = chol(Sigma);

X = randn(nParsEq, nVars);

B = meanB + cholCovB * X * cholSigmaTr;

end