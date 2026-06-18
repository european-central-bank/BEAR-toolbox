    function pars = drawLogLambdaSV(pars, prior, numEn, estimLength, Y, LX)

      invA  = largeshockUtils.unvech(pars.F, 0, 1);
      logLambda = pars.logLambda;

      cholPhi = largeshockUtils.unvech(pars.cholPhi);

      resid = Y - LX * pars.B;

      rotResid  = invA * resid';

      [gridKSC, gridKSCt, logy2offset] = largeshockUtils.getKSC7values(estimLength, numEn);

      logy2resid = log(rotResid.^2 + logy2offset);

      [curr] = ...
        largeshockUtils.StochVolKSCcorrsqrt(logy2resid, logLambda, cholPhi, ...
        prior.meanlogLambda', prior.covlogLambda, ...
        gridKSC, gridKSCt, numEn, estimLength);

      pars.logLambda = curr;

    end