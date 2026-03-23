%% CCMM models
% 
% 
% Tutorial file for showcasing models from the paper _Addressing COVID-19 Outliers 
% in BVARs with Stochastic Volatility estimators by_ Andrea Carriero,Todd E. Clark, 
% Massimiliano Marcellino, Elmar Mertens
%% Housekeeping

clear
close all
clear classes
rehash path

  
import base.*

%% Convenience functions
% The |extremesFunc| function compresses any number of samples (draws from the 
% posterior) into two numbers - the minimum and the maximum.

percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

medianFunc = @(x) median(x, 2);
%% Number of Samples

numPresampled = 100;
%% Prepare meta information for the models
% The meta information is the same as for the standard BVARs.


estimStart = datex.m(1960,3);
estimEnd = datex.m(2021,3);
estimSpan = datex.span(estimStart, estimEnd);

meta = Meta( ...
    endogenous=["RPI","DPCERA3M086SBEA", "INDPRO","CUMFNS","UNRATE", "PAYEMS", "CES0600000007",...
    "CES0600000008", "WPSFD49207", "PCEPI", "HOUST", "SP500", "EXUSUK", "GS5", "GS10", "BAAFFM"], ...
    exogenous=[], ...
    order=12, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    identificationHorizon=20 ...
);

%% Specifying and loading input data


inputTbx = tablex.fromFile("CCMMSV.csv");
dataH = DataHolder(meta, inputTbx);
%% Reduced form models
% There are some common settings for the models described in the paper. Since 
% the models are organized hierarchically—starting from a basic SV model (very 
% similar to the Cogley–Sargent specification) and extending it in two steps, 
% first by introducing outliers and then by allowing for _t_-distributed residuals—the 
% settings are also hierarchical. This means that broader models share parameters 
% with the simpler ones, while introducing additional settings as the model becomes 
% more complex. Therefore we only report here the additional settings for each 
% 
% 
% *Basic SV model*
% Estimator sepcific settings:
% 
% *HeteroskedasticityScale (0.15)* –  prior on the scale of the inverse wishart 
% distribution of the variance of the residual in heteroskedasticity 
% 
% *TurningPoint*  –  Used to set the prior of the transition matrix , since 
% the OLS estimate for its prior mean is computed only up to this point

estimatorR1 = estimator.CCMMSV(meta, Turningpoint = datex.m(2020,3));
modelR1 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR1 ...
);
% 
% *Model with outliers*
% Additional estimator sepcific settings:
% 
% *OutlierFreq (10)*  –  mean outlier frequency, indicating how often outliers 
% are expected to occur (in years)
% 
% *PriorObsYears (10)*  –  strength of the outlier prior, with precision set 
% to reflect the span of prior observations.

estimatorR2 = estimator.CCMMSVO(meta, Turningpoint = datex.m(2020,3), OutlierFreq = 4);
modelR2 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR2 ...
);
% 
% *Model with outliers and _t-_distributed residual*
% Additional estimator sepcific settings:
% 
% *DoFLowerBound (3)*   –  lower bound of degrees of freedom for the Student-t 
% residuals
% 
% *DoFUpperBound (40)*  –  upper bound of degrees of freedom for the Student-t 
% residuals


estimatorR3 = estimator.CCMMSVOT(meta,...
    Turningpoint = datex.m(2020,3), OutlierFreq = 4);

modelR3 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR3 ...
);
%% Estimation/sampling of the reduced form model 


modelR1.initialize();
info1 = modelR1.presample(numPresampled);
modelR1.Presampled{1}

modelR2.initialize();
info2 = modelR2.presample(numPresampled);
modelR2.Presampled{1}

modelR3.initialize();
info3 = modelR3.presample(numPresampled);
modelR3.Presampled{1}

%% Running Unconditional forecast 
% 
% Settig up the forecast range and run the forecast

fcastStart = datex.shift(modelR1.Meta.EstimationEnd,1);
fcastEnd = datex.shift(modelR1.Meta.EstimationEnd, 12); 
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastStart, fcastEnd

fcastTbx1 = modelR1.forecast(fcastSpan);
fcastPrctileTbx1 = tablex.apply(fcastTbx1, prctileFunc);

fcastTbx2 = modelR2.forecast(fcastSpan);
fcastPrctileTbx2 = tablex.apply(fcastTbx2, prctileFunc);

fcastTbx3 = modelR3.forecast(fcastSpan);
fcastPrctileTbx3 = tablex.apply(fcastTbx3, prctileFunc);


% Visualize the unconditional forecast



chartpack.forecastPercentiles( ...
    fcastPrctileTbx1, modelR1, FigureTitle ="Unconditional forecast with base SV")

chartpack.forecastPercentiles( ...
    fcastPrctileTbx2, modelR2, FigureTitle ="Unconditional forecast with outliers")

chartpack.forecastPercentiles( ...
    fcastPrctileTbx3, modelR3, FigureTitle ="Unconditional forecast with outliers and t distributed shocks")