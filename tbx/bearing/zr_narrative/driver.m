
% ------------- Setup -------------

addpath("C:\Users\zolta\Work\MATLAB\BEAR-toolbox-6\tbx\sandbox")

clear, clc, close all

db = load("data/Kilian_Data_Updated.mat");

% ------------- BVAR specification -------------

bvar.order = 24;

bvar.varNames   = string(db.varNames);

bvar.constant = true;

bvar.exogNames  = string.empty();

bvar.prior.type         = "NIW";
bvar.prior.meanB        = zeros(3, 3*24 + 1)';
bvar.prior.precB        = zeros(3*24 + 1);
bvar.prior.dfSigma      = 0;
bvar.prior.scaleSigma   = zeros(3);

bvar.shockNames = [
  "Oil Supply"
  "Aggregate Demand"
  "Oil-specific Demand"
  ]';

% ------------- Calculate posterior -------------

smpl = 1971 : 2015;

bvar = calcPost(bvar, db, smpl);

% ------------- Structural indentification specification -------------

% -------- Keep only stable draws

ident.stable = true;

% -------- Sign and zero restrictions --------

ident.irfSign = array2table(nan(3), "VariableNames", bvar.shockNames, "RowNames", bvar.varNames);

ident.irfSign(["Oil Production Growth", "Economic Activity Index"], "Oil Supply")   = {-1, -1}';
ident.irfSign("Real Oil Price", "Oil Supply")                                       = {+1}; % ??? sign of shock is negative

ident.irfSign(:, "Aggregate Demand")                                                = {1, 1, 1}';

ident.irfSign(["Oil Production Growth", "Real Oil Price"], "Oil-specific Demand")   = {1, 1}';
ident.irfSign("Economic Activity Index", "Oil-specific Demand")                     = {-1};

% -------- Elasticity bounds - -------

% ident.elast = {
%   "Oil Production Growth", "Real Oil Price", "Aggregate Demand",    0, 0.0258; ...
%   "Oil Production Growth", "Real Oil Price", "Oil-specific Demand", 0, 0.0258 ...
% };

% -------- Narrative restrictions --------

% ----- Sign of shock -----

ident.narrSign  = array2table(nan(length(bvar.dates), 3), "VariableNames", bvar.shockNames, ...
  "RowNames", string(datestr(bvar.dates)));

ident.narrSign(datestr(datenum(1990, 8, 1)),  "Oil Supply") = {1};

% ----- Contribution of shock -----

ident.narrContr = { ...
  "Real Oil Price", "Aggregate Demand", datenum(1990, 8, 1), datenum(1990, 8, 1), -1; ...  % -2, -1, 1, 2
  };

% ------------- Sample from the identified posterior -------------

% -------- Order of restriction validation --------
validationOrder = [
  "irfSign"
  "elast"
  "narrSign"
  "narrContr"
  "stable"
  ];

rng(1)

tic

[B, S, w, info] = samplePostIdent(bvar, ident, ...
  "numRequestedDraws", 1000, ...
  "numQDraws", 10, ...
  "numNarrativeResampleDraws", 1000, ...
  "dispStep", 5000, ...
  "validationOrder", validationOrder ...
  );

% ------------- Calculate IRF / VD / histDecomp etc. -------------

Bdyn = B(1 : bvar.nEnParsEq, :, :);

ir      = utils.calcIRF(Bdyn, S, 120);
shocks  = utils.calcStructShocks(B, S, bvar.Y, bvar.X);

elapsed_time = toc;

% fileName = replace("results " + datestr(now), [" ", ":"], "-");
% save(fileName, "bvar", "ident", "B", "S", "w", "ir", "shocks", "info", "elapsed_time");