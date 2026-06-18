function posterior = get_NIW_Posterior(prior, Y, X)

    T = size(Y, 1);
    
    olsB      = X \ Y;
    resid     = Y - X * olsB;
    olsSigma  = resid' * resid / T;
    
    XpX   = X'*X;
    
    B0      = prior.meanB;
    N0      = prior.precB;
    kappa0  = prior.dfSigma;
    Psi0    = prior.scaleSigma;
    
    N1      = N0 + XpX;
    B1      = N1 \ (N0 * B0 + X'*Y);
    kappa1  = kappa0 + T;
    Psi1    = Psi0 + T * olsSigma + (olsB - B0)' * N0 * (N1 \ XpX) * (olsB - B0);
    
    posterior.meanB        = B1;
    posterior.precB        = N1;
    posterior.scaleSigma   = Psi1;
    posterior.dfSigma      = kappa1;
    
    posterior.covB                = inv(posterior.precB);
    posterior.cholCovB            = chol(posterior.covB, "lower");
    posterior.invScaleSigma       = inv(posterior.scaleSigma);
    posterior.cholInvScaleSigma   = chol(posterior.invScaleSigma, "lower");
    
end