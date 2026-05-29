% testnw.m
% Test Minnesota and BetaTV reduced-form estimators using the base.* and
% betaTV.* packages (the same paths the BEARX GUI uses). The sandbox-style
% minnesota.Meta(...) call in the original script went through
% baseWithDummies.Meta which is archived in BEAR 6 (the +baseWithDummies~/
% folder has a tilde suffix making it invisible to MATLAB).

clear
close all
rehash path

inputTbx = tablex.fromCsv("SV.csv");

estimStart = datex.q(1971, 2 + 4);  % +4 init lags for Order=4
estimEnd   = datex.q(2020, 1);
estimSpan  = datex.span(estimStart, estimEnd);


%% Minnesota path (via base.* — what the GUI calls "Minnesota")

meta = base.Meta( ...
    endogenousNames=["YER", "HICSA", "STN"], ...
    exogenousNames=string.empty(1,0), ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=20, ...
    shockNames=["DEM", "SUP", "POL"] ...
);

dataH = base.DataHolder(meta, inputTbx);

estimatorR1 = base.estimator.Minnesota(meta);
display(estimatorR1.Settings);

sumCoeffD = dummies.SumCoeff(Lambda=1e-4);

modelR1 = base.ReducedForm( ...
    Meta=meta, ...
    DataHolder=dataH, ...
    Estimator=estimatorR1, ...
    Dummies={sumCoeffD} ...
);

rng(0)
modelR1.initialize();
info1 = modelR1.presample(1000);
display(info1);


%% BetaTV path (via base.* + base.estimator.BetaTV)
% stabilityThreshold relaxed from default (1.0) to 0.9999 — same as XTVModels.m.
% Without this, TV draws are almost always rejected.

estimatorR2 = base.estimator.BetaTV(meta, stabilityThreshold=0.9999);
display(estimatorR2.Settings);

modelR2 = base.ReducedForm( ...
    Meta=meta, ...
    DataHolder=dataH, ...
    Estimator=estimatorR2 ...
);

rng(0)
modelR2.initialize();
info2 = modelR2.presample(1000);
display(info2);
% NOTE: info2.SampleCount reads 0 because BetaTV is a Gibbs sampler that does
% not increment SampleCounter the same way as accept/reject estimators like
% Minnesota. The actual number of stored presampled draws is what matters:
fprintf("BetaTV: %d presampled draws stored.\n", modelR2.NumPresampled);

fprintf("\ntestnw completed.\n");
