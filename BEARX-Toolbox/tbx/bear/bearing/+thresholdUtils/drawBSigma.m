function [B, sigma, tmp] = drawBSigma(sigma, th, delay, thresholdvar,...
                Y, LX, dummiesYLX)            
    for r = 1:2

        regimeInd = thresholdUtils.getRegimeInd(th, delay, thresholdvar, r);

        [Yreg, LXreg] = dummies.addDummiesToData(Y(regimeInd, :), LX(regimeInd, :), ...
            dummiesYLX);

        postMeanB = LXreg \ Yreg;
        cholInvXpX = chol(inv(LXreg'*LXreg), "lower");
        C = chol(sigma(:, :, r) , "lower");
        B(:, :, r) = postMeanB + cholInvXpX * randn(size(postMeanB)) * C';  

        Shat = (Yreg - LXreg * B(:, :, r))' * (Yreg - LXreg * B(:, :, r));
        sigma(:, :, r) = bear.iwdraw(Shat, size(Yreg, 1));

        tmp.("B" + string(r)) = B(:, :, r);
        tmp.("sigma" + string(r)) = sigma(:, :, r);

    end

end