function pars = drawPhi(pars, prior, numEn, estimLength)
        
    priorScalePhi   = prior.scalePhi;
    priorDofPhi     = prior.dofPhi;
    
    logLambda       = pars.logLambda;
    residLogLambda  = diff(logLambda, [], 2);
    
    postDofPhi  = priorDofPhi + estimLength;
    
    % -------------
    
    % This part again comes from the original code.
    
    postScalePhi      = priorScalePhi + residLogLambda*residLogLambda';
    cholPostScalePhi  = chol(postScalePhi, 'lower');
    
    z = randn(numEn, postDofPhi);
    
    cholZZ    = chol(z * z');
    sqrtDraw  = cholPostScalePhi / cholZZ;
    draw      = sqrtDraw * sqrtDraw';
    
    % -------------
    
    cholDraw = chol(draw, "lower");
    pars.cholPhi = largeshockUtils.vech(cholDraw);

end