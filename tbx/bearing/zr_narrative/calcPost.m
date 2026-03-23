function bvar = calcPost(bvar, db, smpl)

arguments
  bvar
  db
  smpl
end

[Y, X, dates] = utils.prepareData(bvar, db, smpl);

bvar.nVars      = size(Y, 2);
bvar.nParsEq    = size(X, 2);
bvar.nEnParsEq  = bvar.nVars * bvar.order;
bvar.nExParsEq  = bvar.nParsEq - bvar.nEnParsEq;
bvar.nPars      = bvar.nVars * bvar.nParsEq;

T = size(Y, 1);

olsB      = X \ Y;
resid     = Y - X * olsB;
olsSigma  = resid' * resid / T;

XpX   = X'*X;

switch bvar.prior.type

  case "NIW"

    B0      = bvar.prior.meanB;
    N0      = bvar.prior.precB;
    kappa0  = bvar.prior.dfSigma;
    Psi0    = bvar.prior.scaleSigma;

    N1      = N0 + XpX;
    B1      = N1 \ (N0 * B0 + X'*Y);
    kappa1  = kappa0 + T;
    Psi1    = Psi0 + T * olsSigma + (olsB - B0)' * N0 * (N1 \ XpX) * (olsB - B0);

    bvar.posterior.precB        = N1;
    bvar.posterior.meanB        = B1;
    bvar.posterior.dfSigma      = kappa1;
    bvar.posterior.scaleSigma   = Psi1;

    bvar.posterior.cholInvScaleSigma  = chol(inv(bvar.posterior.scaleSigma), "lower");
    bvar.posterior.cholInvPrecB       = chol(inv(bvar.posterior.precB), "lower");

    bvar.samplePost = @() utils.randNIW( ...
      bvar.posterior.meanB, ...
      bvar.posterior.cholInvPrecB, ...
      bvar.posterior.cholInvScaleSigma, ...
      bvar.posterior.dfSigma ...
      );

end

bvar.Y = Y;
bvar.X = X;
bvar.T = T;

bvar.dates = dates;

bvar.resid = resid;

end