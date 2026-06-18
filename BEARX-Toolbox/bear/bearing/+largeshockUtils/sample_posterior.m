function [B, Sigma] = sample_posterior(posterior)

    nVars = size(posterior.cholInvScaleSigma, 1);
    X = randn(nVars, posterior.dfSigma);
    A = posterior.cholInvScaleSigma * X;
    AAt = A*A';
    
    Sigma   = AAt \ eye(nVars);
    
    % B
    nPars = numel(posterior.meanB);
    nParsEq = nPars / nVars;
    X = randn(nParsEq, nVars);
    B = posterior.meanB + posterior.cholCovB * X * chol(Sigma);

end