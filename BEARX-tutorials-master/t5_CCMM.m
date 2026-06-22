%[text] # CCMM models
%[text] Tutorial file for showcasing models from the paper *Addressing COVID-19 Outliers in BVARs with Stochastic Volatility estimators by* Andrea Carriero,Todd E. Clark, Massimiliano Marcellino, Elmar Mertens
%[text:tableOfContents]{"heading":"**Table of Contents**"}
%%
%[text] ## Housekeeping
clear
close all %[output:6a6915a5] %[output:4cd507bc] %[output:5bfa65c0] %[output:756ca864] %[output:624c286e] %[output:8ed1cdb5] %[output:4cefdc1a] %[output:639b12c0] %[output:490ae955] %[output:9d10010c] %[output:3d9ca268] %[output:474fb256]
  
import base.*
%%
%[text] ## Convenience functions
%[text] The `extremesFunc` function compresses any number of samples (draws from the posterior) into two numbers - the minimum and the maximum.
percentiles = [10, 50, 90];

prctileFunc = @(x) prctile(x, percentiles, 2);

extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

medianFunc = @(x) median(x, 2);
%[text] ## Number of Samples
numPresampled = 100;
%%
%[text] ## Prepare meta information for the models
%[text] The meta information is the same as for the standard BVARs.

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

%%
%[text] ## Specifying and loading input data

inputTbx = tablex.fromFile("data/CCMMSV.csv");
dataH = DataHolder(meta, inputTbx);
%%
%[text] ## Reduced form models
%[text] There are some common settings for the models described in the paper. Since the models are organized hierarchically—starting from a basic SV model (very similar to the Cogley–Sargent specification) and extending it in two steps, first by introducing outliers and then by allowing for *t*-distributed residuals—the settings are also hierarchical. This means that broader models share parameters with the simpler ones, while introducing additional settings as the model becomes more complex. Therefore we only report here the additional settings for each 
%[text] 
%[text] #### **Basic SV model**
%[text] Estimator sepcific settings:
%[text] **HeteroskedasticityScale (0.15)** –  prior on the scale of the inverse wishart distribution of the variance of the residual in heteroskedasticity 
%[text] **TurningPoint** –  Used to set the prior of the transition matrix , since the OLS estimate for its prior mean is computed only up to this point
estimatorR1 = estimator.CCMMSV(meta, Turningpoint = datex.m(2020,3));
modelR1 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR1 ...
);
%[text] #### 
%[text] #### **Model with outliers**
%[text] Additional estimator sepcific settings:
%[text] **OutlierFreq (10)**  –  mean outlier frequency, indicating how often outliers are expected to occur (in years)
%[text] **PriorObsYears (10)** –  strength of the outlier prior, with precision set to reflect the span of prior observations.
estimatorR2 = estimator.CCMMSVO(meta, Turningpoint = datex.m(2020,3), OutlierFreq = 4);
modelR2 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR2 ...
);
%[text] #### 
%[text] #### **Model with outliers and** \*\*\*t-\*\*\***distributed residual**
%[text] Additional estimator sepcific settings:
%[text] **DoFLowerBound (3)**   –  lower bound of degrees of freedom for the Student-t residuals
%[text] **DoFUpperBound (40)**  –  upper bound of degrees of freedom for the Student-t residuals

estimatorR3 = estimator.CCMMSVOT(meta,...
    Turningpoint = datex.m(2020,3), OutlierFreq = 4);

modelR3 = ReducedForm( ...
    meta=meta, ...
    dataHolder=dataH, ...
    estimator=estimatorR3 ...
);
%%
%[text] ## Estimation/sampling of the reduced form model 

modelR1.initialize();
info1 = modelR1.presample(numPresampled); %[output:695d5250]
modelR1.Presampled{1}

modelR2.initialize();
info2 = modelR2.presample(numPresampled);
modelR2.Presampled{1}

modelR3.initialize();
info3 = modelR3.presample(numPresampled);
modelR3.Presampled{1}

%%
%[text] ## Running Unconditional forecast 
%[text] 
%[text] ### Setting up the forecast range and run the forecast
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


%[text] ### Visualize the unconditional forecast


chartpack.forecastPercentiles( ...
    fcastPrctileTbx1, modelR1, FigureTitle ="Unconditional forecast with base SV")

chartpack.forecastPercentiles( ...
    fcastPrctileTbx2, modelR2, FigureTitle ="Unconditional forecast with outliers")

chartpack.forecastPercentiles( ...
    fcastPrctileTbx3, modelR3, FigureTitle ="Unconditional forecast with outliers and t distributed shocks")

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":43.1}
%---
%[output:6a6915a5]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:4cd507bc]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:5bfa65c0]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:756ca864]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:624c286e]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:8ed1cdb5]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:4cefdc1a]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:639b12c0]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:490ae955]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:9d10010c]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:3d9ca268]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'onCleanup' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:474fb256]
%   data: {"dataType":"warning","outputData":{"text":"Warning: Objects of 'datetime' class exist.  Cannot clear this class or any of its superclasses."}}
%---
%[output:695d5250]
%   data: {"dataType":"text","outputData":{"text":"\n Presampling from posterior (CCMMSV) [100]\n ――――――――――――――――――――――――――――――――――――――――――◼―――――――  85% ","truncated":false}}
%---
