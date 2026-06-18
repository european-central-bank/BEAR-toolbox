    function logPostPDF = postlSVpdf(pars, prior, Y, LX)

      % Can not use the method of the superclass, since that is fixed volatility

      B = pars.B;

      [cholSigma, H , F] = largeshockUtils.get_CholSigma(pars);
      resid = Y - LX * B;

      T = size(resid, 1);
      logLik = 0;
      for t = 1 : T
          logLik = logLik + largeshockUtils.mvnlpdf(resid(t, :), cholSigma(:, :, t));
      end

      logH        = log(H);
      cholPhi     = largeshockUtils.unvech(pars.cholPhi);

      dlogH = diff(logH');

      logPriorPDF = ...
          + largeshockUtils.mvnlpdf((B(:) - prior.meanB(:))', prior.cholCovB) ...
          + largeshockUtils.mvnlpdf((F(:) - prior.meanF(:))', prior.cholCovF) ...
          + sum(largeshockUtils.iwlpdf(cholPhi, prior.scalePhi, prior.dofPhi)) ...
          + largeshockUtils.mvnlpdf(prior.meanlogLambda, prior.cholCovlogLambda) ...
          + sum(largeshockUtils.mvnlpdf(dlogH, cholPhi));

      logPostPDF = logLik + logPriorPDF;
    end