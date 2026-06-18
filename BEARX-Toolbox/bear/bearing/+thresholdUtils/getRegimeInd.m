function regimeInd = getRegimeInd(th, delay, thresholdvar, r)
      regimeInd = (thresholdvar(:, delay) <= th);
      if r == 2
        regimeInd = ~regimeInd;
      end
end