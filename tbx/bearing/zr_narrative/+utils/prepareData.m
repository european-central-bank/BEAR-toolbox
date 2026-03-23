function [Y, X, dates] = prepareData(bvar, db, smpl)

% --- Make sure names are string vectors ---
varNames    = string(bvar.varNames);
exogNames   = string(bvar.exogNames);
dbNames     = string(db.varNames);

% --- Get dimensions ---
T = length(db.dates);
n = length(bvar.varNames);

% --- Collect the endgenous data ---
Y = nan(T, n);
for i = 1 : n
  Y(:, i) = db.data(:, varNames(i) == dbNames);
end

% --- Create the lagged data matrix ---
X = nan(T, n*bvar.order);
ind = 1 : n;
for l = 1 : bvar.order
  X(l+1 : end, ind) = Y(1 : end-l, :);
  ind = ind + n;
end

% --- Add 1-s if a constant is required ---
if bvar.constant
  X = [X, ones(T, 1)];
end

% --- Add exogenous variables if required ---

if ~isempty(bvar.exogNames)

  nEx = length(bvar.exogNames);

  exog = nan(T, nEx);
  for i = 1 : nEx
    exog(:, i) = db.data(:, exogNames(i) == dbNames);
  end

  X = [X, exog];

end

% --- Clip to the sample ---

% --- Remove rows with missing observations ---
nanRows = any(isnan([Y, X]), 2);
Y       = Y(~nanRows, :);
X       = X(~nanRows, :);
dates   = db.dates(~nanRows); 

end