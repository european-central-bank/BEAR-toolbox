function [Y, LX] = getRegimeData(th, delay, thresholdvar,...
    Y, LX, dummy, r)

  regimeInd = thresholdUtils.getRegimeInd(th, delay, thresholdvar, r);

  Y = [Y(regimeInd, :); dummy.Y];
  LX = [LX(regimeInd, :); dummy.X];

end