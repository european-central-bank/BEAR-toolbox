function [B, S, wResmpl, info] = samplePostIdent(bvar, ident, options)

arguments
  bvar
  ident
  options.validationOrder           (1,:) string                                  = string(fieldnames(ident));
  options.numRequestedDraws         (1,1) double {mustBeInteger, mustBePositive}  = 10000
  options.numQDraws                 (1,1) double {mustBeInteger, mustBePositive}  = 100
  options.numNarrativeResampleDraws (1,1) double {mustBeInteger, mustBePositive}  = 1000
  options.dispStep                  (1,1) double {mustBeInteger, mustBePositive}  = 100
end

% ------------- Process inputs -------------

% -------- Process data from the BVAR results --------

nVars       = bvar.nVars;
nParsEq     = bvar.nParsEq;
nEnParsEq   = bvar.nEnParsEq;
samplePost  = bvar.samplePost;

% -------- Process identifying restrictions --------

[ident, irfHor] = utils.processIdent(ident, bvar);

% -------- Porcess options --------

nDraws        = options.numRequestedDraws;
nQDraws       = options.numQDraws;
nResmplDraws  = options.numNarrativeResampleDraws;
dispStep      = options.dispStep;
valOrder      = options.validationOrder;

doNarr = any(contains(valOrder, "narrSign") | contains(valOrder, "narrContr"));

if doNarr

  % ----- Calculate structural shocks only in the periods of interest -----

  narrSignPeriods   = find(any(~isnan(ident.narrSign), 2));
  narrContrPeriods  = min(ident.narrContr(:,3)) : max(ident.narrContr(:,4));
  narrPeriods       = unique([narrSignPeriods; narrContrPeriods]);

  Y   = bvar.Y(narrPeriods, :);
  X   = bvar.X(narrPeriods, :);

  ident.narrSign = ident.narrSign(narrPeriods, :);

  ident.narrContr(:, 3) = ident.narrContr(:, 3) - narrPeriods(1) + 1;
  ident.narrContr(:, 4) = ident.narrContr(:, 4) - narrPeriods(1) + 1;

end

% ----- Create validation function handles and iteration counters -----

valFuncs   = struct();
info      = struct();

for s = valOrder

  funcString = "@(bvar, ident, cand, ir, shocks) validate." + s + "(bvar, ident, cand, ir, shocks)";
  valFuncs.(s) = str2func(funcString);

  info.(s) = 0;

end

info.total = 0;
info.valid = 0;

% ------------- Main loop -------------

B   = nan(nParsEq,  nVars, nDraws);
S   = nan(nVars,    nVars, nDraws);

shocks    = [];
wResmpl   = nan(nDraws, 1);

while info.valid < nDraws

  % -------- Draw from the unrestricted posterior --------
  [cand.B, cand.Sigma] = samplePost();
  cand.Bdyn = cand.B(1 : nEnParsEq, :);

  % -------- Base decomposition --------
  cand.P = chol(cand.Sigma, "lower");

  for i = 1 : nQDraws

    info.total = info.total + 1;

    % -------- Draw a uniform orthogonal matrix satisfying the zero restrictions --------
    if any(ident.irfSign.zero(:) == 0)
      Q = utils.randOrth(nVars, candP, ident.zeroRestr);
    else
      Q = utils.randOrth(nVars);
    end

    % -------- Calculate the structural decomposition, the IRF, and structural shocks --------

    cand.S  = cand.P * Q;
    ir      = utils.calcIRF(cand.Bdyn, cand.S, irfHor);

    if doNarr
      shocks  = utils.calcStructShocks(cand.B, cand.S, Y, X);
    end

    % -------- Check restrictions --------

    valid = true;
    for s = valOrder
      valid = valFuncs.(s)(bvar, ident, cand, ir, shocks);
      if ~valid
        break
      else
        info.(s) = info.(s) + 1;
      end
    end

    % -------- Store valid draws and calculate weights for resampling --------

    if valid

      info.valid = info.valid + 1;

      B(:, :, info.valid) = cand.B;
      S(:, :, info.valid) = cand.S;

      if doNarr
        wResmpl(info.valid) = calcResamplingWeight(bvar, ident, cand, ir, nResmplDraws);
      end

    end

    % -------- Display iteration info --------

    if rem(info.total, dispStep) == 0
      fmtString = "Total: %9.0f"; % Could be outside the main loop
      dispVals  = {info.total};
      for s = valOrder
        fmtString   = [fmtString, s + ": %6.0f"]; %#ok<AGROW>
        dispVals    = [dispVals, {info.(s)}]; %#ok<AGROW>
      end
      fmtString = join(fmtString, ", ") + "\n";
      fprintf(fmtString, dispVals{:});
    end

  end

end

% -------- Delete unrequested valid draws --------

% ----- We may have more if 1 < nQDraws -----
B = B(:, :, 1 : nDraws);
S = S(:, :, 1 : nDraws);
wResmpl = wResmpl(1 : nDraws);

% -------- Resample --------

if doNarr
  ind = utils.randInd(nDraws, nDraws, wResmpl);
  B = B(:, :, ind);
  S = S(:, :, ind);
end

end

% ------------------------------------------------
% ------------- End of main function -------------

function weight = calcResamplingWeight(bvar, ident, cand, ir, nResmplDraws)

resmplDraws = nan(nResmplDraws, 1);

for i = 1 : nResmplDraws
  shocks = randn(bvar.T, bvar.nVars);
  chk1 = validate.narrSign(bvar, ident, cand, ir, shocks);
  chk2 = validate.narrContr(bvar, ident, cand, ir, shocks);
  resmplDraws(i) = chk1 && chk2;
end

weight = nResmplDraws / sum(resmplDraws);

end
