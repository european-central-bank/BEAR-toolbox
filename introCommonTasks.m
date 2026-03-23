%% Introduction to common tasks
%% 
% * Read data from different sources
% * Set up the components for a reduced-form VAR model
% * Estimate a reduced-form VAR model
% * Run common tasks with reduced-form VAR model
% * Set up the components for a structural identification of a VAR model
% * Identify a structural VAR model from its original reduced form
% * Run common tasks with structural VAR model
% * Use multiple VAR models (objects) at the same time
% * Use basic visualization tools
%% Housekeeping


clear
close all
rehash path

addpath ../sandbox
addpath ../bear

%% Convenience functions
% These functions will be used when manipulating some of the output tables


percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

firstFunc = @(x) x(:, 1, :, :, :);

medianFunc = @(x) median(x, 2);

flatFunc = @(x) x(:, :);

defaultColors = get(0, "defaultAxesColorOrder");


%% Reading data
%% 
% * CSV
% * Excel
% * MAT file


inputTbx = tablex.fromCsv("exampleData.csv");


inputTbx

%% Setting up components for reduced-form VAR model 
%% 
% * Meta information
% * Data holder
% * Estimator
% * Dummy observations
% * Transformer


estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = base.Meta( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"], ...
    units="", ...
    exogenous="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan ...
);

meta

dataH = base.DataHolder(meta, inputTbx);

estimatorR = estimator.NormalWishart( ...
    meta ...
);

estimatorR

% estimatorR2 = estimator.GeneralTV(meta, Burnin=100);
% estimatorR2.Settings

minnesotaD = dummies.Minnesota(exogenousLambda=30);

modelR = base.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
    , dummies={minnesotaD} ...
    , stabilityThreshold=Inf ...
);

modelR

%% Initializing reduced-form VAR model
% 
% 
% The initialization step precalculates all the values needed for running a 
% posterior simulator, creates the following function handles (accessible as properties 
% of the reduced-form objec):
% |.Sampler|
% A function returning one sample from the posterior distribution
% |.IdentificationDrawer|
% A function taking one sample and returning a sequence (cell array) of VAR 
% system matrices |A|, |C| and a fixed covariance matrix |Sigma| used for calculating 
% shock responses. This sequence is generated only once for each sample and cached 
% within the model object.
% |.HistoryDrawer|
% A function taking one sample and returning a sequence (cell array) of |A|, 
% |C|, and |Sigma| matrices with their historical estimates (in time-varying models) 
% or simply their estimates repeated the corresponding number of times.
% |.UnconditionalDrawer|
% A function taking one sample, a start date (index), and a forecast horizon 
% lenght, and generates a sequence (cell array) of |A|, |C|, and |Sigma| matrices 
% meant for calculating an unconditional forecast on the given forecast span. 
% This sequence is not cached: 
%% 
% * for time-invariant models, the function simply returns a sequence of fixed 
% system matrices;
% * for time-varying models, the function generates (randomly) using the estimated 
% probabilistic assumptions about the time evolution of the model parameters.
% |.ConditionalDrawer|
% Same as |.UnconditionalDrawer| but for conditional forecasts.
% 
% 


modelR.initialize();

modelR

%% Presampling from posterior
% 
% 
% Generate a specified number of samples from the posterior distributions. These 
% samples are cached, and use in all of the subsequent calculations.
% 
% 


modelR.presample(100);

modelR

%% Using reduced-form VAR model
% 
% 
% Using the estimated reduced-form model, run the following calculations:
%% 
% * Estimate the historical reduals (one set of residuals for each sample)
% * Run an unconditional forecast (within historical range)


residTbx = modelR.estimateResiduals();


fcastStart = datex.shift(modelR.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastStart, fcastEnd

fcastTbx = modelR.forecast(fcastSpan);
keeyboard
fcastTbx

fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
fcastPrctileTbx

tablex.plot( ...
    fcastPrctileTbx, "DOM_GDP", ...
    plotSettings={"color", defaultColors(1, :), {"lineStyle"}, {":"; "-"; ":"}} ...
);

%% Setting up components for structural VAR
% 


id = identifier.Cholesky();

modelS = base.Structural( ...
    reducedForm=modelR, ...
    identifier=id ...
);

modelS

%% Identifying structural VAR
% 


modelS.initialize();

modelS

info = modelS.presample(100);

info

%% Using structural VAR


fcastTbx = modelS.forecast(fcastSpan);

residTbx = modelS.estimateResiduals();

shkTbx = modelS.estimateShocks();

simTbx = modelS.simulateResponses();
simPctTbx = tablex.apply(simTbx, prctileFunc);
simPctTbx = tablex.flatten(simPctTbx);

ch = visual.Chartpack( ...
    span=tablex.span(simPctTbx), ...
    namesToPlot=tablex.names(simPctTbx), ...
    captions="Shock Responses" ...
);
ch.plot(simPctTbx);

%% Structural identification with general restrictions



testStrings = [
    "abs($SHKRESP(1, 'DOM_GDP', 'POL')) > 0"
    "$SHKEST('2014-Q1', 'DEM') > 0.1"
    "$SHKCONT('2010-Q3', 'DOM_CPI', 'SUP') > 0"
]

id2 = identifier.Verifiables(testStrings, maxCandidates=50);

modelS = base.Structural( ...
    reducedForm=modelR, ...
    identifier=id2 ...
);


modelS.initialize()
info = modelS.presample(100);
info

%% Using structural VAR



shkTbx = modelS.estimateShocks();
simTbx = modelS.simulateResponses();

contTbx = modelS.breakdown();
fcastTbx = modelS.forecast(fcastSpan);
fevdTbx = modelS.calculateFEVD();

tablex.getHigherDims(contTbx)

contMedTbx = tablex.apply(contTbx, medianFunc);
contMedTbx = tablex.apply(contMedTbx, flatFunc);

ch = visual.Chartpack( ...
    span=datex.span("2010-Q1", "2014-Q4"), ...
    namesToPlot=modelS.Meta.EndogenousNames, ...
    captions="Breakdown of historical observations (Median)", ...
    plotFunc=@bar ...
);
ch.plot(contMedTbx);
leg = tablex.getHigherDims(contMedTbx);
legend(leg{1});