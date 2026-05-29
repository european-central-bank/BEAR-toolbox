% test7_meanAdjusted.m
% Plain-text version of t7_meanAdjusted.mlx (mean-adjusted BVAR with
% trends and regimes).

clear
close all
clear classes
rehash path

addpath ../BEARX-Toolbox/tbx/bear -end
addpath ../BEARX-Toolbox/tbx/bearing -end

import mean.*

percentiles  = [10, 50, 90];
prctileFunc  = @(x) prctile(x, percentiles, 2);
medianFunc   = @(x) median(x, 2);

numPresampled = 1000;

estimStart = datex.q(1972, 1);
estimEnd   = datex.q(2020, 1);
estimSpan  = datex.span(estimStart, estimEnd);

turningPoint1 = datex.q(2008, 1);
turningPoint2 = datex.q(2014, 4);

inputTbx = tablex.fromFile("SV.csv");

meta = Meta( ...
    endogenousNames=["YER", "HICSA", "STN"], ...
    order=4, ...
    estimationSpan=estimSpan, ...
    trendType=["time", "constant", "constant"], ...
    numRegimes=[2, 2, 1], ...
    regimeSpans={ ...
        {[datex.span(estimStart, turningPoint1), ...
          datex.span(datex.shift(turningPoint2, 1), estimEnd)]}, ...
        {datex.span(datex.shift(turningPoint1, 1), turningPoint2)} ...
    }, ...
    bounds={{[]}, {[1 4], [0 2]}, {[2 5]}}, ...
    identificationHorizon=20 ...
);

dataH = DataHolder(meta, inputTbx);

estimatorR = estimator.MeanAdjusted(meta, ScaleUp=100);

modelR = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR ...
);

display(modelR.Estimator.Settings);
modelR.initialize();
info = modelR.presample(numPresampled);
display(info);

%% Forecast
fcastStart = datex.shift(modelR.Meta.EstimationEnd, 1);
fcastEnd   = datex.shift(modelR.Meta.EstimationEnd, 12);
fcastSpan  = datex.span(fcastStart, fcastEnd);

fcastTbx        = modelR.forecast(fcastSpan);
fcastPrctileTbx = tablex.apply(fcastTbx, prctileFunc);
display(fcastPrctileTbx);

fprintf("\ntest7_meanAdjusted completed.\n");
