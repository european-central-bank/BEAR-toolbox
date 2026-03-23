function [identOut, irfHor] = processIdent(identIn, bvar)

varNames    = bvar.varNames;
shockNames  = bvar.shockNames;
dates       = bvar.dates;

irfHor = -inf;

% -------- Stability --------

identOut.stable = identIn.stable;

% -------- Sign restrictions on the IRF --------

zeroRestr   = [];
signRestr   = [];

if isfield(identIn, "irfSign")

  R = identIn.irfSign{:, :};

  if any(R(:) == 0)
    zeroRestr = R;
  end

  signRestr = R;
  signRestr(signRestr == 0) = NaN;

  irfHor = max(irfHor, 0);

end

identOut.irfSign.zero  = zeroRestr;
identOut.irfSign.sign  = signRestr;

% -------- Elasticity restrictions --------

elastRestr = [];

if isfield(identIn, "elast")

  elastRestr = nan(size(identIn.elast));
  for j = 1 : size(elastRestr, 1)
    elastRestr(:, 1)   = find(identIn.elast{j, 1} == varNames);
    elastRestr(:, 2)   = find(identIn.elast{j, 2} == varNames);
    elastRestr(:, 3)   = find(identIn.elast{j, 3} == shockNames);
    elastRestr(:, 4)   = [identIn.elast{j, 4}];
    elastRestr(:, 5)   = [identIn.elast{j, 5}];
  end

  irfHor = max(irfHor, max(elastRestr(:, 4)));

end

identOut.elast = elastRestr;

% -------- Narrative restrictions on structural shock signs --------

narrSign = [];

if isfield(identIn, "narrSign")

  narrSign = identIn.narrSign{:, :};

end

identOut.narrSign = narrSign;

% -------- Narrative restrictions on structural shock contributions --------

narrContr = [];

if isfield(identIn, "narrContr")

  narrContr = nan(size(identIn.narrContr));

  for j = 1 : size(narrContr, 1)
    narrContr(:, 1)   = find(identIn.narrContr{j, 1} == varNames);
    narrContr(:, 2)   = find(identIn.narrContr{j, 2} == shockNames);
    narrContr(:, 3)   = find(identIn.narrContr{j, 3} == dates);
    narrContr(:, 4)   = find(identIn.narrContr{j, 4} == dates);
    narrContr(:, 5)   = identIn.narrContr{j, 5};
  end

  irfHor = max(irfHor, max(narrContr(:, 4) - narrContr(:, 3)));

end

identOut.narrContr = narrContr;

end