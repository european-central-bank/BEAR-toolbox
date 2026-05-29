%% Panel models (no cross-sections) - one-country variant


%% Clear workspace

clear
close all
rehash path

addpath ../BEARX-Toolbox/tbx/bear -end
addpath ../BEARX-Toolbox/tbx/bearing -end



%% Convenience functions

percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

defaultColors = get(0, "defaultAxesColorOrder");


%% Prepare data and a reduced-form model

inputTbx = tablex.fromCsv("panel_data.csv");

estimStart = datex.q(1972, 1);
estimEnd   = datex.q(2014, 4);
estimSpan  = datex.span(estimStart, estimEnd);

meta = separable.Meta( ...
    endogenousConcepts=["YER", "HICSA", "STN"], ...
    units=["US", "EA"], ...
    exogenousNames=["Oil"], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

disp(meta);


%% Create a data holder

dataH = separable.DataHolder(meta, inputTbx);

disp(dataH);


%% Select model

numSamples = 100;

% Random effect - Zellner Hong
estimatorR = separable.estimator.ZellnerHongPanel(meta);

estimatorR.Settings


%% Reduced form model

modelR = separable.ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR ...
);

rng(0)
modelR.initialize();
info = modelR.presample(numSamples);
disp(info);


%% Specify exact zero restrictions

instantZerosTbx = tablex.forInstantZeros(modelR);
instantZerosTbx{"HICSA", "DEM"} = 0;
instantZerosTbx{"STN",   "SUP"} = 0;

disp(instantZerosTbx)


%% Identify a SVAR using exact zero restrictions

identInstantZeros = identifier.InstantZeros(table=instantZerosTbx);

disp(identInstantZeros);

modelS1 = separable.Structural( ...
    reducedForm=modelR, ...
    identifier=identInstantZeros ...
);

disp(modelS1);

modelS1.initialize();
info1 = modelS1.presample(100);

respTbx1 = modelS1.simulateResponses();
respTbx1 = tablex.apply(respTbx1, extremesFunc);
respTbx1 = tablex.flatten(respTbx1);

disp(respTbx1)


%% Estimate residuals

residTbx = modelR.estimateResiduals();

residTbx %#ok<NOPTS>


%% Run unconditional forecast

fcastStart = datex.shift(estimEnd, -9);
fcastEnd   = datex.shift(estimEnd,  0);
fcastSpan  = datex.span(fcastStart, fcastEnd);

fcastTb = modelR.forecast(fcastSpan);

fcastTb %#ok<NOPTS>


%% Identify a SVAR using Cholesky

identChol = identifier.Cholesky(ordering=["HICSA", "STN"]);

modelS = separable.Structural(reducedForm=modelR, identifier=identChol);
modelS.initialize();
info = modelS.presample(numSamples);


%% Simulate shock responses

resp = modelS.simulateResponses();


%% Plot results

respTbx = tablex.apply(resp, prctileFunc);
respTbx = tablex.flatten(respTbx);

respTbx %#ok<NOPTS>

tablex.plot(respTbx, "US_YER___DEM");
title("US GDP (demand shock)");


%% Unconditional forecast

fcastStart = datex.shift(modelS.Meta.EstimationEnd, -10);
fcastEnd   = datex.shift(modelS.Meta.EstimationEnd,   0);
fcastSpan  = datex.span(fcastStart, fcastEnd);

fcastTbx = modelS.forecast(fcastSpan);
fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
fcastPrctileTbx = tablex.flatten(fcastPrctileTbx);

fcastTbx %#ok<NOPTS>

tablex.plot( ...
    fcastPrctileTbx, "US_YER", ...
    plotSettings={{"lineStyle"}, {":"; "-"; ":"}} ...
);
title("US GDP");


%% Calculate FEVD

fevd = modelS.calculateFEVD();


%% Conditional forecast - setup

fcastStart = datex.shift(estimEnd,  1);
fcastEnd   = datex.shift(estimEnd, 12);
fcastSpan  = datex.span(fcastStart, fcastEnd);
initStart  = datex.shift(fcastStart, -modelS.Meta.Order);

[dataTbx, planTbx] = tablex.forConditional(modelS, fcastSpan);

dataTbx{datex("2015-Q1"), "US_YER"}   = -1.5;
dataTbx{datex("2015-Q4"), "EA_HICSA"} =  5.5;
dataTbx{:, "Oil"} = inputTbx{end, "Oil"};

dataTbx %#ok<NOPTS>
planTbx %#ok<NOPTS>


%% Conditional forecast - run

% Shock names in the plan accept either the unprefixed concept ("DEM",
% "POL", ...) or the unit-prefixed global form ("US_DEM", "EA_SUP", ...).
% BEAR normalizes both to per-unit indices internally (cf. Bug 8 patch
% in +conditional/createShocksCF.m).
planTbx{datex.q(2015,1), "US_YER"}   = "DEM POL";
planTbx{datex.q(2015,4), "EA_HICSA"} = "DEM SUP";

planTbx %#ok<NOPTS>

% NOTE: across-the-board variant (plan=[]) triggers a BEAR-internal bug
% in +conditional/forecast.m line 22 (cellfun on a non-cell []). Skipped
% until BEAR is patched; only the selective variant runs below.
% rng(0);
% cfcastTbx1 = modelS.conditionalForecast(fcastSpan, conditions=dataTbx, plan=[], exogenousFrom="conditions");
% cfcastPrctilesTbx1 = tablex.apply(cfcastTbx1, prctileFunc);

rng(0);
cfcastTbx2 = modelS.conditionalForecast(fcastSpan, conditions=dataTbx, plan=planTbx, exogenousFrom="conditions");
cfcastPrctilesTbx2 = tablex.apply(cfcastTbx2, prctileFunc);


%% Plot conditional forecasts

plotSettings = { ...
    {"color"},     {defaultColors(2,:); defaultColors(1,:); defaultColors(2,:)}, ...
    {"lineStyle"}, {":"; "-"; ":"} ...
};

ch = visual.Chartpack( ...
    span=datex.span(initStart, fcastEnd), ...
    namesToPlot=[modelS.Meta.EndogenousNames, modelS.Meta.ShockNames], ...
    plotSettings=plotSettings ...
);

% PATCH: Chartpack.plot internally passes plotFunc= to tablex.plot which
% is a BEAR-internal bug. cfcastPrctilesTbx1 also undefined (plan=[] skipped).
% ch.Captions = "Across-the-board conditional forecast";
% ch.plot(cfcastPrctilesTbx1);
% ch.Captions = "Selective conditional forecast";
% ch.plot(cfcastPrctilesTbx2);
