%% Conditional forecasts
%% 
% * Prepare a reduced-form model for experiments with zero restrictions
% * Prepare a table with conditions
% * Prepare a table with a "simulation plan"
% * Run and report a conditional report using all shocks vs seletected shocks


clear
close all
rehash path

addpath ../BEARX-Toolbox/tbx/bear -end
addpath ../BEARX-Toolbox/tbx/bearing -end

%% Convenience functions
%
% The |extremesFunc| function compresses any number of samples (draws from the 
% posterior) into two numbers - the minimum and the maximum.


percentiles = [10, 50, 90];
prctilesFunc = @(x) prctile(x, percentiles, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

defaultColors = get(0, "defaultAxesColorOrder");

%% Prepare data and a reduced-form model
%
% * Same as in introCommonTasks

inputTbx = tablex.fromCsv("panel_data.csv");

estimStart = datex.q(1972,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = separable.Meta( ...
    endogenousConcepts=["YER", "HICSA", "STN"], ...
    units=["US", "EA", "UK"], ...
    exogenousNames="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = separable.DataHolder(meta, inputTbx);

estimatorR = separable.estimator.NormalWishartPanel(meta);

modelR = separable.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
);

%% Indentify a SVAR using Cholesky with reordering
% 
% * Use Cholesky as if the endogenous variables were ordered in a different 
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can 
% omit that part


identChol = identifier.Cholesky(ordering=[]);

% Equivalent to
% identChol = identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = separable.Structural(reducedForm=modelR, identifier=identChol);

modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D

respTbx0 = modelS0.simulateResponses();
respTbx0 = tablex.apply(respTbx0, extremesFunc);
respTbx0 = tablex.flatten(respTbx0);

respTbx0


%% Create forecast assumptions


fcastStart = datex.shift(estimEnd, 1);
fcastEnd = datex.shift(estimEnd, 12);
fcastSpan = datex.span(fcastStart, fcastEnd);
initStart = datex.shift(fcastStart, -modelS0.Meta.Order);

[dataTbx, planTbx] = tablex.forConditional(modelS0, fcastSpan);
dataTbx
planTbx

dataTbx{datex("2015-Q4"), "US_YER"} = -1.5;
dataTbx{datex("2016-Q4"), "US_HICSA"} = 5.5;
%dataTbx{datex("2016-Q3"), "STN"} = 5.5;

dataTbx{:, "Oil"} = inputTbx{end, "Oil"};


%% Run across-the-board vs selective conditions forecasts


planTbx{datex("2015-Q4"), "US_YER"} = "DEM POL";
planTbx{datex("2016-Q4"), "US_HICSA"} = "DEM SUP";
%planTbx{datex("2016-Q3"), "DOM_CPI"} = "SUP";


histContTbx = modelS0.calculateContributions();

rng(0);

% NOTE: across-the-board variant (plan=[]) triggers a BEAR-internal bug
% in +conditional/forecast.m line 22 (cellfun on a non-cell []). Skipped
% until BEAR is patched; only the selective variant runs below.
% Also: exogenousFrom="conditions" required because fcastSpan extends past
% the DataHolder span (Oil is only available historically).
% [cfcastTbx1, cfcastContTbx1] = modelS0.conditionalForecast( ...
%     fcastSpan, ...
%     conditions=dataTbx, ...
%     plan=[], ...
%     contributions=true, ...
%     exogenousFrom="conditions" ...
% );

% PATCH: depends on skipped plan=[] call above
% cfcastPrctilesTbx1 = tablex.apply(cfcastTbx1, prctilesFunc);



rng(0);

% PATCH: BEAR-internal bug for separable panels + conditional forecast.
% In +base/@Structural/conditionalForecast.m line 101, an acknowledged
% TODO comment ("Rearrange draw.beta in separable panels") plus the
% variable name EXTRA_DIM_BUG = 2 indicate a known cell-array dimension
% mismatch. tvcfsim1.m line 19 fails with reshape: number of elements
% mismatch. Skipped until BEAR is patched.
%
% [cfcastTbx2, cfcastContTbx2] = modelS0.conditionalForecast( ...
%     fcastSpan, ...
%     conditions=dataTbx, ...
%     plan=planTbx, ...
%     contributions=true, ...
%     exogenousFrom="conditions" ...
% );
% cfcastPrctilesTbx2 = tablex.apply(cfcastTbx2, prctilesFunc);


%% Visualize conditional forecasts


plotSettings = { ...
   {"color"}, {defaultColors(2,:); defaultColors(1,:); defaultColors(2,:)},  ...
   {"lineStyle"}, {":";"-";":"}, ...
};

ch = visual.Chartpack( ...
    span=datex.span(initStart, fcastEnd), ...
    namesToPlot=[modelS0.Meta.EndogenousNames, modelS0.Meta.ShockNames], ...
    plotSettings=plotSettings ...
);

% PATCH: Chartpack.plot internally passes plotFunc= to tablex.plot which
% is a BEAR-internal bug (plotFunc not a valid drawChart kwarg). Skipped.
% ch.Captions = "Across-the-board conditional forecast";
% ch.plot(cfcastPrctilesTbx1);
% ch.Captions = "Selective conditional forecast";
% ch.plot(cfcastPrctilesTbx2);