% test6_mixedFrequency.m
% Plain-text version of t6_mixedFrequency.mlx with a data-prep fix.
%
% The CSV mixed_frequency_data_transformed.csv ships with the low-frequency
% series (ygdp) forward-filled to every month. mixed.estimator.MixedFrequency
% expects the low-frequency series to be NaN except at quarter-ends, so its
% Kalman filter alternates between the "Y_q observed" and "Y_q missing"
% branches. Forward-filled data sends every row down the "observed" branch,
% which eventually breaks the dimension bookkeeping
% (Phat = GAMMAs*Pt1*GAMMAs' + ...).
%
% Fix: blank out ygdp on non-quarter-end months (keep only Mar/Jun/Sep/Dec).

clear
close all
clear classes
rehash path

addpath ../BEARX-Toolbox/tbx/bear -end
addpath ../BEARX-Toolbox/tbx/bearing -end

import mixed.*

percentiles = [10, 50, 90];
prctileFunc = @(x) prctile(x, percentiles, 2);
medianFunc  = @(x) median(x, 2);

numPresampled = 1000;

estimStart = datex.m(2001, 1);
estimEnd   = datex.m(2021, 2);
estimSpan  = datex.span(estimStart, estimEnd);

meta = Meta( ...
    highFrequencyNames=["ipi", "ZEW", "DAX", "ifoclimate", ...
        "ifoexpectations", "Retail", "Manufacturingsales", ...
        "Autprod", "Worldtrade", "WorldIP"], ...
    lowFrequencyNames="ygdp", ...
    order=6, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=12 ...
);

inputTbl = tablex.fromFile("mixed_frequency_data_transformed.csv");

%% --- Fix A: mask forward-filled low-frequency observations ---
% Keep ygdp only at the end of each quarter (Mar/Jun/Sep/Dec).
months = month(inputTbl.Time);
isQuarterEnd = ismember(months, [3, 6, 9, 12]);
inputTbl.ygdp(~isQuarterEnd) = NaN;
%% --- end fix ---

dataH = DataHolder(meta, inputTbl);
estimatorR1 = estimator.MixedFrequency(meta);
display(estimatorR1);

modelR1 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR1 ...
);

modelR1.initialize();
info0 = modelR1.presample(numPresampled);
display(info0);

%% NOTE on the structural identification step
% The original t6_mixedFrequency.mlx Live Script continues with a Cholesky
% identification cell:
%
%   identChol = identifier.Cholesky(ordering=[]);
%   modelS1   = Structural(reducedForm=modelR1, identifier=identChol);
%   modelS1.initialize();
%   modelS1.presample(numPresampled);
%
% That cell fails with a dimension-mismatch error inside
% mixed.estimator.MixedFrequency/initializeSampler/sampler (line 217):
%   Phat = GAMMAs * Pt1 * GAMMAs' + GAMMAu * sig_qq * GAMMAu';
%
% Root cause: the Kalman filter closure stores Pmean only inside one branch
% of the recursion (around line 364). On a second sampler invocation -
% which the structural identifier triggers via redSampler() - Pt is
% restored from Pmean, which can be [] or wrongly sized. This is an
% upstream toolbox bug in mixed.estimator.MixedFrequency, not in the
% tutorial. Reduced-form mixed-frequency works fine, so this script
% intentionally stops here.

fprintf("\ntest6_mixedFrequency completed (reduced-form only).\n");
