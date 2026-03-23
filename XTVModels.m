%% TV models
%% 
% * Prepare time-varying models
% * Identify a SVAR using Cholesky
% * Checking TV features of the model (beta/sigma) in estimation/IRF/forecast



clear
close all
clear classes
rehash path

addpath ../sandbox
addpath ../bear

%% Convenience functions
% 

percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

medianFunc = @(x) prctile(x, 50, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

numPresampled = 100;


%% Prepare data and a reduced-form model

inputTbx = tablex.fromCsv("SV.csv");

estimStart = datex.q(1971,2);
estimEnd = datex.q(2020,1);
estimSpan = datex.span(estimStart, estimEnd);

meta = model.Meta( ...
    endogenous=["YER", "HICSA", "STN"], ...
    units="", ...
    exogenous=[], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=20, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = model.DataHolder(meta, inputTbx);

%% Set up time-varying models

% Time-varying coefficients (BetaTV)


estimatorR1 = estimator.BetaTV(meta, stabilityThreshold=0.9999);

modelR1 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR1 ...
);

modelR1.Estimator.Settings
modelR1.initialize();
modelR1.presample(50);

return

s = [];
for i = 1 : 50
    s = [s, modelR1.Presampled{i}.AbsMaxEigval];
end

return


% General time-varying (i.e parameters and covariance are both TV)

estimatorR2 = estimator.GeneralTV(meta);

modelR2 = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR2 ...
);
modelR2.Estimator.Settings


%% Indentify a SVAR using Cholesky (without reordering)
% Time-varying coefficients (BetaTV)


identChol = identifier.Cholesky(order=[]);

modelS1 = model.Structural(reducedForm=modelR1, identifier=identChol);
modelS1.initialize();
info1 = modelS1.presample(numPresampled);
modelS1.Presampled{1}
modelS1.Presampled{1}.IdentificationDraw
modelS1.Presampled{1}.IdentificationDraw.A{1,1}
modelS1.Presampled{1}.IdentificationDraw.A{2,1}


%% 
% and General time-varying


modelS2 = model.Structural(reducedForm=modelR2, identifier=identChol);
modelS2.initialize();
info2 = modelS2.presample(numPresampled);
modelS2.Presampled{1}
modelS2.Presampled{1}.IdentificationDraw
modelS2.Presampled{1}.IdentificationDraw.A{1,1}
modelS2.Presampled{1}.IdentificationDraw.A{2,1}


%% Impulse responses
% Time-varying coefficients (BetaTV)

respTbx1 = modelS1.simulateResponses();
respTbx1 = tablex.apply(respTbx1, prctileFunc);
respTbx1 = tablex.flatten(respTbx1);

respTbx1

tablex.plot(respTbx1,"YER___DEM")
%% 
% and General time-varying

respTbx2 = modelS2.simulateResponses();
respTbx2 = tablex.apply(respTbx2, prctileFunc);
respTbx2 = tablex.flatten(respTbx2);

respTbx2

tablex.plot(respTbx2,"YER___DEM")
%% Unconditional forecast 


fcastStart = datex.shift(modelS1.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelS1.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

% Time-varying coefficients (BetaTV)

histContTbx = modelS1.calculateContributions();

fcastTbx1 = modelS1.forecast(fcastSpan);


fcastPrctileTbx1 = tablex.apply(fcastTbx1, prctileFunc);
fcastPrctileTbx1 = tablex.flatten(fcastPrctileTbx1);

fcastTbx1

tablex.plot( ...
    fcastPrctileTbx1, "YER", ...
    plotSettings={{"lineStyle"}, {":"; "-"; ":"}} ...
);

% General time-varying

fcastTbx2 = modelS2.forecast(fcastSpan);

fcastPrctileTbx2 = tablex.apply(fcastTbx2, prctileFunc);
fcastPrctileTbx2 = tablex.flatten(fcastPrctileTbx2);

fcastTbx2

tablex.plot( ...
    fcastPrctileTbx2, "YER", ...
    plotSettings={{"lineStyle"}, {":"; "-"; ":"}} ...
);


%% Decomposition of the unconditional forecast

% Simulate the forecast including the decomposition into contributions
[fcastTbx1, fcastContTbx1] = modelS1.forecast( ...
    fcastSpan, ...
    contributions=true ...
);

% Extract labels (used later in the chart)
contLabels = tablex.getHigherDims(medianCont);
contLabels = contLabels{1};

% Calculate median contributions
medianCont = tablex.apply(fcastContTbx1, medianFunc);

% Extract contributions of shocks
medianContShocks = tablex.apply(medianContTbx1, @(x) x(:, :, 1:end-2));

% Extract contributions of exogenous variables including intercept
medianContExog = tablex.apply(medianContTbx1, @(x) x(:, :, end-1));

% Extract contributions of initial condition
medianContInit = tablex.apply(medianContTbx1, @(x) x(:, :, end));

figure();
hold on
tablex.plot(medianContShocks, "YER", plotFunc="bar");
tablex.plot(medianContExog, "YER", plotSettings={"color", "black", "lineWidth", 2});
tablex.plot(medianContInit, "YER", plotSettings={"color", "red", "lineWidth", 2});

legend(contLabels);

