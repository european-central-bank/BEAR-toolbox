

close all
clear
clear classes
rehash path
addpath ../bear

rng(0);

pctileFunc = @(x) prctile(x, [5, 50, 95], 2);

% master = bear6.run(configStruct=configStruct);
% config = master.Config;

config = struct();

config.data = struct( ...
    "format", "csv", ...
    "source", "+tv/panel_data.csv" ...
);

config.meta = struct( ...
    "endogenous", ["YER", "HICSA", "STN"], ...
    "units", ["US", "EA", "UK"], ...
    "exogenous", ["Oil"], ...
    "order", 4, ...
    "estimationStart", "1972-Q1", ...
    "estimationEnd", "2014-Q4", ...
    "intercept", true ...
);

% histLegacy = tablex.fromCsv("exampleDataLegacy.csv", dateFormat="legacy");
% hist = tablex.fromCsv("exampleData.csv");

inputTable = bear6.readInputData(config.data);

% dataSpan = tablex.span(inputTable);
% estimSpan = dataSpan;

metaR = meta.ReducedForm( ...
    endogenous=config.meta.endogenous ...
    , exogenous=config.meta.exogenous ...
    , units=config.meta.units ...
    , order=config.meta.order ...
    , intercept=config.meta.intercept ...
    , estimationSpan=datex.span(config.meta.estimationStart, config.meta.estimationEnd) ...
);

% estimator = estimator.StaticCrossPanel(metaR);
% estimator = estimator.DynamicCrossPanel(metaR);
% estimator = estimator.HierarchicalPanel(metaR);
estimator = estimator.NormalWishartPanel(metaR);
% estimator = estimator.ZellnerHongPanel(metaR);
% estimator = estimator.MeanOLSPanel(metaR);

dataHolder = model.DataHolder(metaR, inputTable);

modelR = model.ReducedForm( ...
    meta=metaR ...
    , data=dataHolder ...
    , estimator=estimator ...
    , stabilityThreshold=Inf ...
);

modelR.initialize();
modelR.presample(100);

fcastStart = datex.shift(modelR.Meta.EstimationEnd, -3);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, +8);
fcastSpan = datex.span(fcastStart, fcastEnd);
rng("default")

% fcastTable = modelR.forecast(fcastSpan);
% fcastPctTable = tablex.apply(fcastTable, pctileFunc);

% residTbx = modelR.calculateResiduals();
keyboard
metaS = meta.Structural(metaR, identificationHorizon=20);

id = identifier.Cholesky(stdVec=1);

modelS = model.Structural(meta=metaS, reducedForm=modelR, identifier=id);
modelS.initialize()
modelS.presample(100);

%% Conditional forecast

longYXZ = modelR.getLongYXZ();

% Conditional forecast type. Hardcoded as 2 for now.
% CFt = this.Settings.CFt;
% "all shocks"
% CFt = 1;
% "selected shocks"
CFt = 2;

% Panel model type. Here, we theoretically only need to distiguish if it is with cross-sections or not. I hard code it as 2 for NormalWishartPanel (no cross-sections).
% "with cross-sections"
% panel = 5;
% "no cross-sections"
panel = 2;

fStart = lower(datestr(fcastStart,'YYYYQQ'));
fEnd = lower(datestr(fcastEnd,'YYYYQQ'));
Fperiods = length(fcastSpan);

% Load conditional forecast conditions
% dirty house
% [cfcondsFull, cfshocksFull, cfblocksFull] = bear.loadcfpan(endo, units, panel, CFt, fStart, fEnd, Fperiods, pref);
% my simple example function
[cfcondsFull, cfshocksFull, cfblocksFull] = tv.set_conditions_example(panel, CFt, Fperiods, metaR);

[cforecast_record] = tv.conditionalForecastPanel(metaR, fcastStart, fcastEnd, longYXZ, cfcondsFull, cfshocksFull, cfblocksFull);
