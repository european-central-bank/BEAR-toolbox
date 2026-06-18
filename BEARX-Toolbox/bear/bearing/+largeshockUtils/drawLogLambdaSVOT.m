function pars = drawLogLambdaSVOT(pars, prior, numEn, estimLength, Y, LX)
    
    
    [gridKSC, gridKSCt, logy2offset] = largeshockUtils.getKSC7values(estimLength, numEn);
    
    resid = Y - LX * pars.B;
    
    invA  = largeshockUtils.unvech(pars.F, 0, 1);
    A_    = invA;
    
    yresid2      = (resid*A_').^2;
    logyresid2   = log(yresid2 + logy2offset);
    
    logLambda   = pars.logLambda;
    Vol_states  = logLambda;
    
    cholPhi   = pars.cholPhi;
    sqrtPHI_  = largeshockUtils.unvech(cholPhi);
    
    Vol_0mean     = prior.meanlogLambda(:); % !!!
    Vol_0vcvsqrt  = prior.covlogLambda;
    
    O       = pars.O;
    SVOlog2 = 2*log(O);
    
    SVOprob = pars.probO;
    
    SVOalpha = prior.alphaProbO(1);
    
    SVObeta  = prior.betaProbO(1);
    
    SVOmaxscale           = 20;
    SVOstates.Ngrid       = SVOmaxscale - 1;
    SVOstates.values      = 1 : SVOmaxscale;
    SVOstates.log2values  = 2 * log(SVOstates.values);
    
    tdof.values        = prior.lbDofQ(1) : prior.ubDofQ(1);
    tdof.Ndof          = numel(tdof.values);
    tdof.logprior      = repmat(-log(tdof.Ndof), 1, tdof.Ndof);
    tdof.loglike0      = estimLength * (.5 * tdof.values .* log(tdof.values) + gammaln(.5 * (tdof.values + 1)) - gammaln(.5 * tdof.values) - gammaln(.5));
    
    [Vol_states, ~, ~,  ~, ~, SVOprob, SVOscale, SVtscalelog2, SVtdof] = ...
        largeshockUtils.StochVoltOutlier(yresid2', logyresid2', Vol_states, sqrtPHI_, Vol_0mean, Vol_0vcvsqrt, ...
        SVOlog2, SVOprob, SVOalpha, SVObeta, SVOstates, ...
        tdof, gridKSC, gridKSCt, numEn, estimLength);
    
    pars.logLambda   = Vol_states;   
    pars.O     = SVOscale;   
    pars.probO = SVOprob;  
    pars.Q     = exp(SVtscalelog2 / 2);
    pars.dofQ  = SVtdof;

end
