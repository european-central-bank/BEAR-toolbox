function prior = get_MH_Prior_new(beta0, omega0, sigma)

    numBrows = size(sigma, 1);
    numEn = size(sigma, 1);
    prior.meanB = reshape(beta0, [], numBrows);
        
    % Prior for Sigma
    prior.scaleSigma   = sigma;
    prior.dfSigma = numEn + 2;
    
    % Calculate transformations to be used later in sampling (not sure if needed here)
    prior.covB                = omega0;
    prior.precB               = inv(omega0);
    prior.cholCovB            = chol(prior.covB, "lower");
    prior.cholScaleSigma      = chol(prior.scaleSigma, "lower");
    prior.invScaleSigma       = inv(prior.scaleSigma);
    prior.cholInvScaleSigma   = chol(prior.invScaleSigma, "lower");

end