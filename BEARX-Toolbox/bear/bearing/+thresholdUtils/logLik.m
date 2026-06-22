function y = logLik(B, sigma, th, delay, thresholdvar, Y, LX)
    y = 0;
    for r = 1 : 2
        regimeInd = thresholdUtils.getRegimeInd(th, delay, thresholdvar, r);
        Yreg = Y(regimeInd, :);
        LXreg = LX(regimeInd, :);
        Breg = B(:, :, r);
        resid = Yreg - LXreg * Breg;
        y = y + sum(largeshockUtils.mvnlpdf(resid, chol(sigma(:, :, r),"lower")));
    end
end


