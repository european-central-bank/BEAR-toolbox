function th = drawThreshold(B, sigma, th, delay, thresholdvar,...
    meanThreshold, varThreshold, Y, LX, propStd)
        
    currLPDF  = thresholdUtils.logPostPDF(B, sigma, th, delay,...
        thresholdvar,meanThreshold, varThreshold, Y, LX);
    

    cand      = th + propStd * randn();
    candLPDF  = thresholdUtils.logPostPDF(B, sigma, cand, delay,...
        thresholdvar, meanThreshold, varThreshold, Y, LX);

    alpha     = min(1, exp(candLPDF - currLPDF));
    
    u = rand();
    accepted  =  u < alpha;
    
    if accepted
        th = cand;
    end
   

end
