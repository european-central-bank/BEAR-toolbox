
%% Panel models 

clear
close all
clear classes
rehash path

import cross.*


%% Prepare data and a reduced-form model

inputTbx = tablex.fromCsv("panel_data.csv");

estimStart = datex("1972-Q1");
estimEnd = datex("2014-Q4");
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenous=["YER", "HICSA", "STN"], ...
    units=["US", "EA", "UK"], ...
    exogenous=["Oil"], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=20, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = DataHolder(meta, inputTbx);

numSamples = 100;
rng(0);


%% Cross-sectional static model

estimatorR5 = estimator.StaticCrossPanel(meta);
estimatorR5.Settings

modelR5 = ReducedForm(meta=meta, dataHolder=dataH, estimator=estimatorR5);

rng(0);
modelR5.initialize();
info5 = modelR5.presample(numSamples);
% disp('Beta Median Static Cross Panel Model:')
% betaMedian5 = calcMedian(modelR5,"beta")



%% Cross-sectional Dynamic model
% This one is the most complicated and takes a lot of time to sample. Not going 
% to run it here now. It is already

estimatorR6 = estimator.DynamicCrossPanel(meta);
estimatorR6.Settings

modelR6 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR6 ...
);

rng(0);
modelR6.initialize();
info6 = modelR6.presample(10);


%% Indentify a SVAR using Cholesky (without reordering)

identChol = identifier.Cholesky(ordering=[]);

modelS5 = Structural(reducedForm=modelR5, identifier=identChol);
modelS5.initialize();
info5 = modelS5.presample(numSamples);

modelS5.Presampled{1}
modelS5.Presampled{1}.IdentificationDraw
modelS5.Presampled{1}.IdentificationDraw.A{1,1}
modelS5.Presampled{1}.IdentificationDraw.A{2,1}


modelS6 = Structural(reducedForm=modelR6, identifier=identChol);
modelS6.initialize();
info6 = modelS6.presample(10);


%% Impulse responses

% Static model

prctileFunc = @(x) prctile(x, [10, 50, 90], 2);
resp5 = modelS5.simulateResponses();
respPct5 = tablex.apply(resp5, prctileFunc);
respPct5 = tablex.flatten(respPct5);

resp5
respPct5


%% Plot results

close all

figure();
tablex.plot(respPct5, "US_YER___US_DEM");
title("US_YER___US_DEM", interpreter="none");

figure();
tablex.plot(respPct5, "EA_YER___US_DEM");
title("EA_YER___US_DEM", interpreter="none");

