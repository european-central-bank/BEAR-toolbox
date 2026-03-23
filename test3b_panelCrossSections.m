%% Panel models with cross sections
% 
% 
% Tutorial file for testing panel models
%% Housekeeping

clear
close all
clear classes
rehash path

import cross.*  

%% Convenience functions
% 

percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

medianFunc = @(x) median(x, 2);

flatFunc = @(x) x(:, :);

defaultColors = get(0, "defaultAxesColorOrder");
%% Number of Samples

numPresampled = 100;
%% Prepare meta information for the models
% 
% 
% Note that the meta information is common to all cross-section panel BVAR models, 
% regardless of the specific estimator used.
% 
% The properties are as follows:
% 
% *endogenousConcepts* –  a list of endogenous variables, listed without the 
% country suffix. Plays the same role as *endogenousNames* in plain BVARs
% 
% *units* – a list of countries/units that share the same endogenous variables


estimStart = datex("1972-Q1");
estimEnd = datex("2014-Q4");
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenousConcepts=["YER", "HICSA", "STN"], ...
    units=["US", "EA", "UK"], ...
    exogenous=["Oil"], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=20, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);


%% Specifying and loading input data


inputTbl = tablex.fromFile("panelData.csv");
dataH = DataHolder(meta, inputTbl);
%% 
%% Reduced form models
% There are some common properties for the cross section panel BVARs. Which 
% are
% 
% 
% 
% *Alpha0 (1000)* – The shape of the Inverse Gamma distribution of residual 
% variances
% 
% *Delta0 (1)* – The scale of the Inverse Gamma distribution of residual variances
% 
% Static Cross Panel
% 

estimatorR1 = estimator.StaticCrossPanel(meta);
% 
% Dynamic Cross Panel
% 
% 
% *A0 (1000)* – The shape of the Inverse Gamma distribution of factor variances
% 
% *B0 (1)* – The scale of the Inverse Gamma distribution of factor variances
% 
% *Rho (0.75)* – The AR coefficient in the prior for factor coefficients.
% 
% *Gamma (0.85)* – The AR coefficient for latent innovation series
% 
% 

% estimatorR1 = estimator.DynamicCrossPanel(meta);
%% 
% 
% Creating the reduced form model


modelR1 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR1 ...
);
%% Estimation/sampling of the reduced form model 


modelR1.initialize();
info0 = modelR1.presample(numPresampled);
modelR1.Presampled{1}.beta

%% 
% 
%% Running Unconditional forecast 
% 
% Settig up the forecast range and run the forecast

fcastStart = datex.shift(modelR1.Meta.EstimationEnd, -10); %The forecast starts 10 periods prior to the end of the estimation span.
fcastEnd = datex.shift(modelR1.Meta.EstimationEnd, 0); %The forecast ends at the end of the estimation window.
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastStart, fcastEnd

fcastTbx = modelR1.forecast(fcastSpan);
fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
fcastPrctileTbx = tablex.flatten(fcastPrctileTbx); %keeping only the pctiles set at the beginning of the file (10, 50, 90)


% Visualize the unconditional forecast


chartpack.forecastPercentiles( ...
    fcastPrctileTbx, modelR1, FigureTitle ="Unconditional forecast")

%% Identification
% 
% Cholesky
% 
% Seting up the identifier

identChol = identifier.Cholesky(order=[]);

modelS1 = Structural(reducedForm=modelR1, identifier=identChol);
modelS1.initialize();

info1 = modelS1.presample(numPresampled);
modelS1.Presampled{1}
% 
% Checking transition matrices

modelS1.Presampled{1}.IdentificationDraw
modelS1.Presampled{1}.IdentificationDraw.A{1,1}
modelS1.Presampled{1}.IdentificationDraw.A{2,1}
% 
% Checking scaling matrix

modelS1.Presampled{1}.D
modelS1.Presampled{2}.D

%% Impulse respones (IRF)
% 
% Cholesky

respTbl1 = modelS1.simulateResponses();
respTbl1 = tablex.apply(respTbl1, prctileFunc);
respTbl1 = tablex.flatten(respTbl1);

respTbl1

chartpack.responsePercentiles( ...
    respTbl1, modelS1 ...
    , "figureTitle", "Shock responses (percentiles)" ...
);
%% *Historical shock decomposition*
% 


histContTbx = modelS1.calculateContributions();

tablex.getHigherDims(histContTbx)

histContMedTbx = tablex.apply(histContTbx, medianFunc);

chartpack.contributionsMedian( ...
    histContMedTbx, modelS1 ...
    , "figureTitle", "Shock contributions with Cholesky (median)" ...
);
%% *Unconditional forecast shock decomposition*
% 


[uncFcastTbl1, uncFcastContribTbl1] = modelS1.forecast( ...
    fcastSpan, ...
    contributions=true ...
);

tablex.getHigherDims(uncFcastContribTbl1)

contMedTbx = tablex.apply(uncFcastContribTbl1, medianFunc);
contMedTbx = tablex.apply(contMedTbx, flatFunc);

chartpack.contributionsMedian( ...
    contMedTbx,modelS1 ...
    , "figureTitle", "Unconditional forecast Shock contributions (median)" ...
);

%% *FEVD*


fevdTbx = modelS1.calculateFEVD();

tablex.getHigherDims(fevdTbx)

fevdMedTbx = tablex.apply(fevdTbx, medianFunc);
fevdMedTbx = tablex.apply(fevdMedTbx, flatFunc);

chartpack.contributionsMedian( ...
    fevdMedTbx,modelS1 ...
    , "figureTitle", "FEVD (median)" ...
);

%% Conditional forecast
% 
% Settig up the conditions and the forecast plan

condDataTbl = tablex.fromFile("condDataTblPanel.xlsx");
planTbl = tablex.readConditioningPlan("planTblPanel.xlsx");
% 
% Settig up the forecast range 

cfcastStart = datex.shift(modelR1.Meta.EstimationEnd, 1); %The forecast starts after the estimation span.
cfcastEnd = datex.shift(modelR1.Meta.EstimationEnd, 12); 
cfcastSpan = datex.span(cfcastStart, cfcastEnd);
% 
% Running conditional forecast with no simulation plan

[condFcastTbl1, condFcastContribTbl1] = modelS1.conditionalForecast( ...
    cfcastSpan, ...
    conditions=condDataTbl, ...
    plan=[], ...
    exogenousFrom = "conditions" ...
);

condFcastPrctilesTbl1 = tablex.apply(condFcastTbl1, prctileFunc);
% 
% Running conditional forecast with simulation plan

[condFcastTbl2, condFcastContribTbl2] = modelS1.conditionalForecast( ...
    cfcastSpan, ...
    conditions=condDataTbl, ...
    plan=planTbl, ...
    exogenousFrom = "conditions" ...
);

condFcastPrctilesTbl2 = tablex.apply(condFcastTbl2, prctileFunc);
% 
% Visualize the conditional forecast

chartpack.conditionalForecastPercentiles( ...
    condFcastPrctilesTbl1,modelS1 ...
    , "figureTitle", "Conditional forecast w/o plan (percentiles)" ...
);

chartpack.conditionalForecastPercentiles( ...
    condFcastPrctilesTbl2,modelS1 ...
    , "figureTitle", "Conditional forecast with plan (percentiles)" ...
);