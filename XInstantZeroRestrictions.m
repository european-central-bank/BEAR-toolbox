%% Instant zero restrictions 

% * Prepare a reduced-form model for experiments with zero restrictions
% * Identify a SVAR using Cholesky with reordering
% * Identify a SVAR based on instant zero restrictions only
% * Combine instant zero restrictions with general restrictions
% * Use tables to specify sign restrictions


clear
clear classes
close all
rehash path

addpath ../bearing -end
addpath ../bear -end

import base.*


%% Convenience functions 

% The `extremesFunc` function compresses any number of samples (draws from the
% posterior) into two numbers - the minimum and the maximum.

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];


%% Prepare data and a reduced-form model 

% * Same as in `introCommonTasks`

inputTbl = tablex.fromCsv("exampleData.csv");

estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenousNames=["DOM_GDP", "DOM_CPI", "STN"], ...
    exogenousNames="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockNames=["DEM", "SUP", "POL"] ...
);

dataH = DataHolder(meta, inputTbl);


estimatorR = estimator.NormalWishart(meta);


modelR = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
);



%% Indentify a SVAR using Cholesky with reordering 

% * Use Cholesky as if the endogenous variables were ordered in a different
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can
% omit that part

identChol = identifier.Cholesky(ordering=["DOM_CPI", "DOM_GDP", "STN"]);

% Equivalent to
% identChol = identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = Structural(reducedForm=modelR, identifier=identChol);

modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D

respTbl0 = modelS0.simulateResponses();
respTbl0 = tablex.apply(respTbl0, extremesFunc);
respTbl0 = tablex.flatten(respTbl0);

respTbl0

contribsTbl0 = modelS0.calculateContributions();


%% Specify instant zero restrictions 

% * Create an empty table for instant zero restrictions using `tablex.forInstantZeros`
% * The table has endogenous variables in rows, shocks in columns
% * Fill in zeros for the elements to be restricted
% * The algorithm can only handle *underdetermined* systems, meaning it must
% have at least one "degree of freedom"; this means the max number of zero restrictions
% is   `n * (n-1) / 2 - 1`
% * The algorithm is able handle an edge case of no restrictions - it simply
% produces fully randomized unconstrained factors of the covariance matrix

instantZerosTbl0 = tablex.forInstantZeros(modelR);
instantZerosTbl0{"DOM_CPI", "DEM"} = 0;
instantZerosTbl0{"STN", "SUP"} = 0;
instantZerosTbl0

tablex.writetable(instantZerosTbl0, "instantZerosTbl.xlsx");
instantZerosTbl = tablex.readtable("instantZerosTbl.xlsx", convertTo=@double);


%% Identify a SVAR using instant zero restrictions 

% * Create an "instant zero" identifier from the instant zeros table
% * Use this identifier to set up a SVAR object
% * Initialize and presample...


identInstantZeros = identifier.InstantZeros(table=instantZerosTbl);

identInstantZeros

modelS1 = Structural(reducedForm=modelR, identifier=identInstantZeros);

modelS1

modelS1.initialize();
info1 = modelS1.presample(100);

return

respTbl1 = modelS1.simulateResponses();
respTbl1 = tablex.apply(respTbl1, extremesFunc);
respTbl1 = tablex.flatten(respTbl1);

respTbl1


%% Identify a SVAR using sign restrictions 

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
    signStrings ...
    , maxCandidates=50 ...
);

modelS2 = Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS2

modelS2.initialize();
info2 = modelS2.presample(100);
info2

respTbl2 = modelS2.simulateResponses();
respTbl2 = tablex.apply(respTbl2, extremesFunc);
respTbl2 = tablex.flatten(respTbl2);

respTbl2


%% Report details of acceptance statistics 

% * Extract the true-false information about success/fail for in

% trackers = [];
% for s = modelS2.Presampled
%     trackers = [trackers, s{:}.Tracker]; %#ok<AGROW>
% end
% 
% statsTbl = table(mean(trackers, 2), variableNames="Success rate", rowNames=signStrings);
% statsTbl



%% Use a table to specify sign restrictions as a convenience feature 

% * Create an "empty" table designed specifically for sign restrictions using
% `tablex.forSignRestrictions`
% * Fill in `1`s and `-1`s for positive and negative signs
% * The table has variable names in rows, shock names in columns, and each table
% element is a vector of `NaN`s, `1`s and `-1`s corresponding to the periods of
% the identification horizon

rng(0);

signTbl = tablex.forSignRestrictions(modelR);
signTbl{"DOM_GDP", "DEM"} = ">0 [2, 3]";
signTbl{"DOM_CPI", "DEM"} = ">0 [2, 3]";
signTbl{"DOM_GDP", "SUP"} = "<0 [2, 3]";
signTbl{"DOM_CPI", "SUP"} = ">0 [2, 3]";

tablex.validateSignRestrictions(signTbl, model=modelR);

testStrings = identifier.SignRestrictions.toVerifiableTestStrings(signTbl, modelR);
testStrings


identVerifiables = identifier.GeneralRestrict( ...
    inequalityRestrictionsTable=signTbl, ...
    maxCandidates=50 ...
);


modelS3 = Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS3

modelS3.initialize();
info3 = modelS3.presample(100);
info3

respTbl3 = modelS3.simulateResponses();
respTbl3 = tablex.apply(respTbl3, extremesFunc);
respTbl3 = tablex.flatten(respTbl3);

respTbl3



%% Identify a SVAR combining instant zeros and sign restrictions 

rng(0);

% signTbl0 = tablex.forIneqRestrict(modelR);
% signTbl0{"DOM_GDP", "DEM"} = ">0 [2, 3]";
% signTbl0{"DOM_CPI", "DEM"} = ">0 [2, 3]";
% signTbl0{"DOM_GDP", "SUP"} = "<0 [2, 3]";
% signTbl0{"DOM_CPI", "SUP"} = ">0 [2, 3]";
% tablex.writetable(signTbl0, "signTbl.xlsx");

signTbl = tablex.readtable("signTbl.xlsx", convertTo=@string);


identVerifiables = identifier.Verifiables( ...
    inequalityRestrictionsTable=signTbl, ...
    instantZeros=identInstantZeros, ...
    maxCandidates=50 ...
);

modelS4 = Structural( ...
    reducedForm=modelR, ...
    identifier=identVerifiables ...
);

modelS4

modelS4.initialize();
info4 = modelS4.presample(100);
info4

respTbl4 = modelS4.simulateResponses();
respTbl4 = tablex.apply(respTbl4, extremesFunc);
respTbl4 = tablex.flatten(respTbl4);

decomp = modelS4.calculateContributions();

respTbl4

