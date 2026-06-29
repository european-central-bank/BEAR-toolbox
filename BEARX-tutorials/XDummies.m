%% Dummy observations 

clear
close all

import base.*
%% Convenience functions 


percentiles = [10, 50, 90];
prctileFunc = @(x) prctile(x, percentiles, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

numSamples = 1000;


%% Prepare data and a reduced-form model 

inputTbx = tablex.fromCsv("data/SV.csv");

estimStart = datex.q(1971, 2);
estimEnd = datex.q(2020, 1);
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenousNames=["YER", "HICSA", "STN"], ...
    exogenousNames=[], ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=20, ...
    shockNames=["DEM", "SUP", "POL"] ...
);

dataH = DataHolder(meta, inputTbx);


estimatorR1 = estimator.NormalWishart(meta);
estimatorR1.Settings
estimatorR1.CanHaveDummies

modelR1 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR1 ...
);


%% Sum of coefficients dummy 

estimatorR2 = estimator.NormalWishart(meta);

sumCoeff = dummies.SumCoeff(lambda=1e-4);
sumCoeff.Lambda

modelR2 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR2 ...
    , dummies={sumCoeff, } ...
);

rng(0)
modelR1.initialize();
info1 = modelR1.presample(numSamples);
betaMedian1 = calcMedian(modelR1, "beta");

rng(0)
modelR2.initialize();
info2 = modelR2.presample(1000);
betaMedian2 = calcMedian(modelR2, "beta");

figure();
scatter(betaMedian1, betaMedian2);
title("Sum of coefficients dummies");


%% Initial observations dummies 

estimatorR3 = estimator.NormalWishart(meta);

initialObs = dummies.InitialObs(lambda=1e-5);
initialObs.Lambda

modelR3 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR3 ...
    , dummies={initialObs, } ...
);

rng(0)
modelR3.initialize();
info3 = modelR3.presample(1000);
betaMedian3 = calcMedian(modelR3, "beta");

figure();
scatter(betaMedian1, betaMedian3);
title("Initial observations dummies");


%% Dummies for long-run constraints 

longRunTbx = tablex.forLongRunDummies(meta);
longRunTbx{"YER", "YER"} = 1;
longRunTbx{"HICSA", "HICSA"} = 1;
longRunTbx{"HICSA", "STN"} = 1;
longRunTbx{"STN", "HICSA"} = -1;
longRunTbx{"STN", "STN"} = 1;

temp = nan(3);
temp(1,1) = 1;
temp(2,2) = 1;
temp(2,3) = 1;
temp(3,2) = -1;
temp(3,3) = 1;

temp = eye(3);

longRun = dummies.LongRun( ...
    ...table=longRunTbx ...
    matrix=temp ...
    , Lambda=1e-4 ...
);

estimatorR4 = estimator.NormalWishart(meta);

modelR4 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR4 ...
    , dummies={longRun} ...
);

rng(0)
modelR4.initialize();
info4 = modelR4.presample(1000);

betaMedian4 = calcMedian(modelR4, "beta");

figure();
scatter(betaMedian1, betaMedian4);
title("Long-run constraints dummies");


%% Combination of dummies

estimatorR7 = estimator.NormalWishart(meta);

modelR7 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR7 ...
    , dummies={sumCoeff, initialObs, longRun} ...
);

rng(0)
modelR7.initialize();
info7 = modelR7.presample(1000);

betaMedian7 = calcMedian(modelR7, "beta");


%% Minnesota dummies 


minnesota = dummies.Minnesota();
minnesota

estimatorR5 = estimator.Ordinary(meta);

modelR5 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR5 ...
    , dummies={minnesota, } ...
);


rng(0)
modelR5.initialize();
info5 = modelR5.presample(numSamples);


betaMedian5 = calcMedian(modelR5, "beta");

estimatorR6 = estimator.Minnesota(meta, sigma="full");

modelR6 = ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR6 ...
);

rng(0)
modelR6.initialize();
info6 = modelR6.presample(numSamples);

betaMedian6 = calcMedian(modelR6, "beta");

figure();
scatter(betaMedian5, betaMedian6);
title("Minnesota dummies vs Minnesota estimator");

