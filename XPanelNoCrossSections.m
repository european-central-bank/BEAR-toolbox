%% Panel models (no cross-sections)


%% Clear workspace
%

clear
clear classes
close all
rehash path


import separable.*


%% Convenience functions
% 

percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

defaultColors = get(0, "defaultAxesColorOrder");



%% Prepare data and a reduced-form model
% 


inputTbx = tablex.fromCsv("panel_data.csv");

estimStart = datex.q(1972,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenousConcepts=["YER", "HICSA", "STN", ], ...
    units=["US", "EA",], ...
    exogenousNames=["Oil", ], ...
    ...order=4, ...
    order=1, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL", ] ...
);

disp(meta);


%% Create a data holder
%

dataH = DataHolder(meta, inputTbx);

disp(dataH);


%% Select model
%

numSamples = 100;

% Mean OLS
estimatorR = estimator.MeanOLSPanel(meta);

% Normal Wishart Models
% estimatorR = estimator.NormalWishartPanel(meta);

% Random effect - Zellner Hong
% estimatorR = estimator.ZellnerHongPanel(meta);

% Random effect - hierarchical
% estimatorR = estimator.HierarchicalPanel(meta);

estimatorR.Settings


%% Reduced form model

modelR = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
);

rng(0)
modelR.initialize();
info = modelR.presample(numSamples);
disp(info);


% disp('Beta Median:')
% betaMedian = calcMedian(modelR,"beta");


%% Specify exact zero restrictions

instantZerosTbx = tablex.forInstantZeros(modelR);

instantZerosTbx{"HICSA", "DEM"} = 0;
instantZerosTbx{"STN", "SUP"} = 0;

disp(instantZerosTbx)


%% Identify a SVAR using exact zero restrictions


identInstantZeros = identifier.InstantZeros(table=instantZerosTbx);

disp(identInstantZeros);

modelS1 = Structural( ...
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


%% Identify a SVAR using sign restrictions

%{
rng(0);

signStrings = [
    "$SHKRESP(2, 'US_YER', 'US_DEM') > 0"
    "$SHKRESP(2, 'US_HICSA', 'US_DEM') > 0"

    "$SHKRESP(3, 'US_YER', 'US_DEM') > 0"
    "$SHKRESP(3, 'US_HICSA', 'US_DEM') > 0"

    "$SHKRESP(2, 'US_YER', 'US_SUP') < 0"    
    "$SHKRESP(2, 'US_HICSA', 'US_SUP') > 0"

    "$SHKRESP(3, 'US_YER', 'US_SUP') < 0"
    "$SHKRESP(3, 'US_HICSA', 'US_SUP') > 0"
]

identVerifiables = identifier.Verifiables( ...
    signStrings, ...
    maxCandidates=50, ...
    shortCircuit=false ...
);

modelS2 = Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS2

modelS2.initialize();
info2 = modelS2.presample(100);
info2

respTbx2 = modelS2.simulateResponses();
respTbx2 = tablex.apply(respTbx2, extremesFunc);
respTbx2 = tablex.flatten(respTbx2);

respTbx2
%}


%% Estimate residuals
% 

residTbx = modelR.estimateResiduals();

residTbx %#ok<NOPTS>


%% Run unconditional forecast
% 


fcastStart = datex.shift(estimEnd, -9);
fcastEnd = datex.shift(estimEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastTb = modelR.forecast(fcastSpan);

fcastTb %#ok<NOPTS>


%% Indentify a SVAR using Cholesky (without reordering)
% 

identChol = identifier.Cholesky(order=["HICSA", "STN"]);

modelS = Structural(reducedForm=modelR, identifier=identChol);
modelS.initialize();
info = modelS.presample(numSamples);


%% Simulate shock responses
%

respTbx = modelS.simulateResponses();


%% Plot results
%

respTbx = tablex.apply(respTbx, prctileFunc);
respTbx = tablex.flatten(respTbx);

respTbx %#ok<NOPTS>


tablex.plot(respTbx, "US_YER___DEM");
title("US GDP (deman shock)");


%% Uncoditional forecast

fcastStart = datex.shift(modelS.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelS.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastTbx = modelS.forecast(fcastSpan);
fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
fcastPrctileTbx = tablex.flatten(fcastPrctileTbx);

fcastTbx %#ok<NOPTS>

tablex.plot( ...
    fcastPrctileTbx, "US_YER", ...
    plotSettings={{"lineStyle"}, {":"; "-"; ":"}} ...
);
title("US GDP");


%% Calcuate FEVD
% 

fevd = modelS.calculateFEVD();


%% Conditional forecast
%
% Create forecast assumptions

fcastStart = datex.shift(estimEnd, 1);
fcastEnd = datex.shift(estimEnd, 12);
fcastSpan = datex.span(fcastStart, fcastEnd);
initStart = datex.shift(fcastStart, -modelS.Meta.Order);

[dataTbx, planTbx] = tablex.forConditional(modelS, fcastSpan);

dataTbx{datex("2015-Q1"), "US_YER"} = -1.5;
dataTbx{datex("2015-Q4"), "EA_HICSA"} = 5.5;
dataTbx{fcastSpan, "Oil"} = 90;
% keyboard
% dataTbx{:, "Oil"} = inputTbx{end, "Oil"};

dataTbx %#ok<NOPTS>
planTbx %#ok<NOPTS>


% Run across-the-board vs selective conditions forecasts

planTbx{datex.q(2015,1), "US_YER"} = "US_DEM US_POL";
planTbx{datex.q(2015,4), "EA_HICSA"} = "EA_DEM EA_SUP";

planTbx %#ok<NOPTS>

rng(0);
cfcastTbx1 = modelS.conditionalForecast(fcastSpan, conditions=dataTbx, plan=[], exogenousFrom = "conditions");

cfcastPrctilesTbx1 = tablex.apply(cfcastTbx1, prctileFunc);

rng(0);
cfcastTbx2 = modelS.conditionalForecast(fcastSpan, conditions=dataTbx, plan=planTbx, exogenousFrom = "conditions");
cfcastPrctilesTbx2 = tablex.apply(cfcastTbx2, prctileFunc);



plotSettings = { ...
   {"color"}, {defaultColors(2,:); defaultColors(1,:); defaultColors(2,:)},  ...
   {"lineStyle"}, {":";"-";":"}, ...
};

ch = visual.Chartpack( ...
    span=datex.span(initStart, fcastEnd), ...
    namesToPlot=[modelS.Meta.EndogenousNames, modelS.Meta.ShockNames], ...
    plotSettings=plotSettings ...
);

ch.Captions = "Across-the-board conditional forecast";
ch.plot(cfcastPrctilesTbx1);

ch.Captions = "Selective conditional forecast";
ch.plot(cfcastPrctilesTbx2);

