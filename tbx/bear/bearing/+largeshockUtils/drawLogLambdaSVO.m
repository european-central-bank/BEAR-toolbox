    function pars = drawLogLambdaSVO(pars, prior, numEn, estimLength, Y, LX)


      [gridKSC, gridKSCt, logy2offset] = largeshockUtils.getKSC7values(estimLength, numEn);

      resid = Y - LX * pars.B;

      invA  = largeshockUtils.unvech(pars.F, 0, 1);
      A_    = invA;

      logy2 = log((resid*A_').^2 + logy2offset);

      logLambda   = pars.logLambda;
      Vol_states  = logLambda;

      cholPhi   = pars.cholPhi;
      sqrtPHI_  = largeshockUtils.unvech(cholPhi);

      Vol_0mean     = prior.meanlogLambda;
      Vol_0vcvsqrt  = prior.covlogLambda;

      O       = pars.O;
      SVOlog2 = 2*log(O);
      

      SVOprob = pars.probO;
      SVOalpha = prior.alphaProbO;
      SVObeta  = prior.betaProbO;

      SVOmaxscale           = 20; % This could perhaps be user-settable
      SVOstates.Ngrid       = SVOmaxscale - 1;
      SVOstates.values      = 1 : SVOmaxscale;
      SVOstates.log2values  = 2 * log(SVOstates.values);
    
      [Vol_states, ~, ~,  ~, ~, SVOprob, SVOscale] = ...
        largeshockUtils.StochVolOutlierKSCcorrsqrt(logy2', Vol_states, sqrtPHI_, Vol_0mean, Vol_0vcvsqrt, ...
        SVOlog2, SVOprob, SVOalpha, SVObeta, SVOstates, ...
        gridKSC, gridKSCt, numEn, estimLength);

      pars.logLambda   = Vol_states;

      pars.O     = SVOscale;
      pars.probO   = SVOprob;

    end