%% Exact zero restrictions

% * Prepare a reduced-form model for experiments with zero restrictions
% * Identify a SVAR using Cholesky with reordering
% * Identify a SVAR based on exact zero restrictions only
% * Combine exact zero restrictions with general restrictions
% * Use tables to specify sign restrictions


clear
close all
rehash path

addpath ../sandbox
addpath ../sandbox/gui
addpath ../bear


%% Convenience functions

% The `extremesFunc` function compresses any number of samples (draws from the
% posterior) into two numbers - the minimum and the maximum.

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];


%% Prepare data and a reduced-form model
%% 
% * Same as in `introCommonTasks`

inputTbx = tablex.fromCsv("exampleData.csv");

estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = model.Meta( ...
    endogenous=["DOM_GDP", "DOM_CPI", "STN"], ...
    units="", ...
    exogenous="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockConcepts=["DEM", "SUP", "POL"] ...
);

dataH = model.DataHolder(meta, inputTbx);

estimatorR = estimator.NormalWishart(meta);

modelR = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
    , stabilityThreshold=Inf ...
);

return

%% Indentify a SVAR using Cholesky with reordering

% * Use Cholesky as if the endogenous variables were ordered in a different 
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can 
% omit that part

identChol = identifier.Cholesky(order=["DOM_CPI", "DOM_GDP", "STN"]);

% Equivalent to
% identChol = identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = model.Structural(reducedForm=modelR, identifier=identChol);

modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D

respTbx0 = modelS0.simulateResponses();
respTbx0 = tablex.apply(respTbx0, extremesFunc);
respTbx0 = tablex.flatten(respTbx0);

respTbx0

decompTbx0 = modelS0.breakdown();


%% Specify exact zero restrictions 

% * Create an empty table for exact zero restrictions using `tablex.forInstantZeros` 
% * The table has endogenous variables in rows, shocks in columns
% * Fill in zeros for the elements to be restricted
% * The algorithm can only handle *underdetermined* systems, meaning it must 
% have at least one "degree of freedom"; this means the max number of zero restrictions 
% is   `n * (n-1) / 2 - 1`
% * The algorithm is able handle an edge case of no restrictions - it simply 
% produces fully randomized unconstrained factors of the covariance matrix


instantZerosTbx = tablex.forInstantZeros(modelR);
instantZerosTbx{"DOM_CPI", "DEM"} = 0;
instantZerosTbx{"STN", "SUP"} = 0;
instantZerosTbx

%% Identify a SVAR using exact zero restrictions
%% 
% * Create an "exact zero" identifier from the exact zeros table
% * Use this identifier to set up a SVAR object
% * Initialize and presample...


identInstantZeros = identifier.InstantZeros(instantZerosTbx);

identInstantZeros

modelS1 = model.Structural(reducedForm=modelR, identifier=identInstantZeros);

modelS1

modelS1.initialize();
info1 = modelS1.presample(100);

respTbx1 = modelS1.simulateResponses();
respTbx1 = tablex.apply(respTbx1, extremesFunc);
respTbx1 = tablex.flatten(respTbx1);

respTbx1


%% Identify a SVAR using sign restrictions
%% 
% * Same as in `introCommonTasks`
%% 
% 

rng(0);

signStrings = [
    "$SHKRESP(2, 'DOM_GDP', 'DEM') > 0"
    "$SHKRESP(2, 'DOM_CPI', 'DEM') > 0"
    
    "$SHKRESP(3, 'DOM_GDP', 'DEM') > 0"
    "$SHKRESP(3, 'DOM_CPI', 'DEM') > 0"

    "$SHKRESP(2, 'DOM_GDP', 'SUP') < 0"    
    "$SHKRESP(2, 'DOM_CPI', 'SUP') > 0"

    "$SHKRESP(3, 'DOM_GDP', 'SUP') < 0"
    "$SHKRESP(3, 'DOM_CPI', 'SUP') > 0"
]

identVerifiables = identifier.Verifiables( ...
    signStrings, ...
    maxCandidates=50, ...
    shortCircuit=false ...
);

modelS2 = model.Structural( ...
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


%% Report details of acceptance statistics

% * Extract the true-false information about success/fail for in

trackers = [];
for s = modelS2.Presampled
    trackers = [trackers, s{:}.Tracker]; %#ok<AGROW>
end

statsTbl = table(mean(trackers, 2), variableNames="Success rate", rowNames=signStrings);
statsTbl



%% Use a table to specify sign restrictions as a convenience feature

% * Create an "empty" table designed specifically for sign restrictions using 
% `tablex.forSignRestrictions`
% * Fill in `1`s and `-1`s for positive and negative signs
% * The table has variable names in rows, shock names in columns, and each table 
% element is a vector of `NaN`s, `1`s and `-1`s corresponding to the periods of 
% the identification horizon

rng(0);

signTbx = tablex.forSignRestrictions(modelR);
signTbx{"DOM_GDP", "DEM"}(2:3) = 1;
signTbx{"DOM_CPI", "DEM"}(2:3) = 1;
signTbx{"DOM_GDP", "SUP"}(2:3) = -1;
signTbx{"DOM_CPI", "SUP"}(2:3) = 1;

testStrings = tablex.toVerifiables(signTbx);
testStrings

identVerifiables = identifier.Verifiables( ...
    signTbx, ...
    maxCandidates=50 ...
);

modelS3 = model.Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS3

modelS3.initialize();
info3 = modelS3.presample(100);
info3

respTbx3 = modelS3.simulateResponses();
respTbx3 = tablex.apply(respTbx3, extremesFunc);
respTbx3 = tablex.flatten(respTbx3);

respTbx3


%% Identify a SVAR combining exact zeros and signs

rng(0);

signTbx = tablex.forSignRestrictions(modelR);
signTbx{"DOM_GDP", "DEM"}(2:3) = 1;
signTbx{"DOM_CPI", "DEM"}(2:3) = 1;
signTbx{"DOM_GDP", "SUP"}(2:3) = -1;
signTbx{"DOM_CPI", "SUP"}(2:3) = 1;

testStrings = tablex.toVerifiables(signTbx);
testStrings

identVerifiables = identifier.Verifiables( ...
    signTbx, ...
    instantZeros=identInstantZeros, ...
    maxCandidates=50 ...
);

modelS4 = model.Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS4

modelS4.initialize();
info4 = modelS4.presample(100);
info4

respTbx4 = modelS4.simulateResponses();
respTbx4 = tablex.apply(respTbx4, extremesFunc);
respTbx4 = tablex.flatten(respTbx4);

decomp = modelS4.breakdown();

respTbx4
