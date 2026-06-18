function pars = drawF(pars, prior, numEn, Y, LX)
        
    resid = Y - LX * pars.B;
    
    H = largeshockUtils.get_H(pars);
    sqrtH   = sqrt(H)';
    
    priorMeanF = prior.meanF(:);
    priorPrecF = prior.precF;
    
    draw = size(pars.F);
    
    firstInd  = 1;
    lastInd   = 1;
    
    for i = 2 : numEn
    
        scaledResid = resid(:, 1:i) ./ sqrtH(:, i);
    
        RR = scaledResid(:, 1:i-1)' * scaledResid(:, 1:i-1);
        Rr = scaledResid(:, 1:i-1)' * scaledResid(:, i);
    
        priorMeani = priorMeanF(firstInd : lastInd);
        priorPreci = priorPrecF(firstInd : lastInd, firstInd : lastInd);
    
        postCovF   = inv(RR + priorPreci);
        postMeanF  = postCovF * (Rr + priorPreci * priorMeani);
    
        draw(firstInd : lastInd) = -(postMeanF + chol(postCovF, 'lower') * randn(i-1, 1));
    
        firstInd  = lastInd + 1;
        lastInd   = lastInd + i;
    
    end
    
    pars.F = draw;

end