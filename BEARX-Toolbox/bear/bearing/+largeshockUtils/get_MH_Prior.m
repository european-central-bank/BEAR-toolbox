function prior = get_MH_Prior(opt, numEn, numBrows, varScale)
    
    lambda1 = opt.lambda1;
    lambda3 = opt.lambda3;
    

    beta0 = zeros(numEn, numEn);
    for idx = 1:numEn
        if isscalar(opt.ar)
            beta0(idx, idx) = opt.ar;
        else
            beta0(idx, idx) = opt.ar(idx, 1);
        end
    end

    prior.meanB = [beta0, zeros(numEn, numBrows - numEn)]';
    
    % Calculate the prior precision for B
    shrinkBeq = nan(numBrows, 1);
    for l = 1 : opt.p
        shrinkBeq((l-1)*numEn+1 : l*numEn) = lambda1^2 * 1/(l^lambda3) ./ varScale;
    end
    
    shrinkBeq(end) = 1e7;
    prior.precB = diag(1./shrinkBeq);
    
    % Prior for Sigma
    prior.scaleSigma   = diag(varScale);
    prior.dfSigma = numEn + 2;
    
    % Calculate transformations to be used later in sampling (not sure if needed here)
    prior.covB                = inv(prior.precB);
    prior.cholCovB            = chol(prior.covB, "lower");
    prior.cholScaleSigma      = chol(prior.scaleSigma, "lower");
    prior.invScaleSigma       = inv(prior.scaleSigma);
    prior.cholInvScaleSigma   = chol(prior.invScaleSigma, "lower");

end