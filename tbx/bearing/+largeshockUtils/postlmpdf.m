function y = postlmpdf(theta, opt, prior, Y, X, T0)
    
    % Posterior log marginal PDF of theta, directly from the paper
    d = prior.dfSigma;
    T = size(Y, 1);
    n = size(Y, 2);
    
    [Y, X, sf] = largeshockUtils.scaleData(Y, X, T0, theta);
    
    XpX = X'*X;
    XpY = X'*Y;
    
    B0  = prior.meanB;
    N0  = prior.precB;
    
    Bhat  = (N0 + XpX) \ (N0 * B0 + XpY);
    eps   = Y - X*Bhat;
    
    cholInvPsi  = prior.cholInvScaleSigma;
    cholOmega   = prior.cholCovB;
    
    A1 = cholOmega' * (XpX) * cholOmega;
    B1 = cholInvPsi' * (eps'*eps + (Bhat - B0)' / cholOmega' / cholOmega * (Bhat - B0)) * cholInvPsi;
    
    lpdfTheta = ...
      + sum(log(gppdf(theta(1:end-1), opt.scaleTheta, opt.shapeTheta, 1))) ...
      + log(betapdf(theta(end), opt.alphaAR, opt.betaAR));
    
    y = ...
      - n * sum(log(sf)) ...
      - n * T/2 * log(pi) ...
      + T * sum(log(diag(cholInvPsi))) ...
      + largeshockUtils.multgammaln((T + d)/2, n) - largeshockUtils.multgammaln(d/2, n) ...
      - n/2 * sum(log(eig(A1) + 1)) ...
      - (T + d)/2 * sum(log(eig(B1) + 1)) ...
      + lpdfTheta;

end
