

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
    "source", "+tv/data_endo.csv" ...
);

config.meta = struct( ...
    "endogenous", ["YER", "HICSA", "STN"], ...
    "exogenous", ["Oil"], ...
    "order", 4, ...
    "estimationStart", "1971-Q2", ...
    "estimationEnd", "2020-Q1", ...
    "intercept", false ...
);

% histLegacy = tablex.fromCsv("exampleDataLegacy.csv", dateFormat="legacy");
% hist = tablex.fromCsv("exampleData.csv");

inputTbx = bear6.readInputData(config.data);

dataSpan = tablex.span(inputTbx);
estimSpan = dataSpan;

metaR = meta.ReducedForm( ...
    endogenous=config.meta.endogenous ...
    , exogenous=config.meta.exogenous ...
    , order=config.meta.order ...
    , intercept=config.meta.intercept ...
    , estimationSpan=datex.span(config.meta.estimationStart, config.meta.estimationEnd) ...
);


% estimator = estimator.GeneralTV(metaR);
% dataH = model.DataHolder(metaR, inputTbx);

estimator = estimator.NormalWishart(metaR);
dataH = data.DataHolder(metaR, inputTbx);



modelR = model.ReducedForm( ...
    meta=metaR ...
    , dataHolder=dataH ...
    , estimator=estimator ...
    , stabilityThreshold=Inf ...
)

modelR.initialize();
modelR.presample(100);


fcastStart = datex.shift(modelR.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastTbx = modelR.forecast(fcastSpan);
residTbx = modelR.calculateResiduals();

metaS = meta.Structural(metaR, identificationHorizon=20);

id = identifier.Triangular(stdVec=1);

% 
% id = identifier.Custom( ...
%     exact=config.identifier.settings.exact, ...
%     verifiable=config.identifier.settings.verifiable ...
% );
% 


modelS = model.Structural(meta=metaS, reducedForm=modelR, identifier=id);
modelS.initialize()
modelS.presample(100);

% Conditional forecast
longYXZ = modelR.getLongYXZ();

% Conditional forecast type. Hardcoded as 2 for now.
% CFt = this.Settings.CFt;
% "all shocks"
% CFt = 1;
% "selected shocks"
CFt = 2;

fStart = lower(datestr(fcastStart,'YYYYQQ'));
fEnd = lower(datestr(fcastEnd,'YYYYQQ'));
Fperiods = length(fcastSpan);

% Load conditional forecast conditions
% my simple example function
[cfcondsFull, cfshocksFull, cfblocksFull] = tv.set_conditions_example(panel, CFt, Fperiods, metaR);

[cforecast_record] = tv.conditionalForecast(modelR, fcastStart, fcastEnd, longYXZ, CFt, panel);
