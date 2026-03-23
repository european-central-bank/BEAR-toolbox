
%% Conditional forecasts 
%
% * Prepare a reduced-form model for experiments with zero restrictions
% * Prepare a table with conditions
% * Prepare a table with a "simulation plan"
% * Run and report an unconditional forecast
% * Run and report a conditional forecast using all shocks vs seletected shocks
% * Calculate and report the contributions of shocks, exogenous, initials
%

clear
close all
rehash path
%#ok<*NOPTS>

addpath ../bear -end
addpath ../sandbox -end
addpath ../sandbox/gui -end


%% Define convenience functions 
%
% The |extremesFunc| function compresses any number of samples (draws from the
% posterior) into two numbers - the minimum and the maximum.


percentiles = [10, 50, 90];
prctilesFunc = @(x) prctile(x, percentiles, 2);
medianFunc = @(x) median(x, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];

defaultColors = get(0, "defaultAxesColorOrder");


%% Prepare data and a reduced-form model 
%
% * Same as in introCommonTasks

inputTbl = tablex.fromCsv("exampleData0.csv");

inputTbl = tablex.extend(inputTbl, -Inf, datex.q(2017,4));
inputTbl.Oil = fillmissing(inputTbl.Oil, "nearest");


estimStart = datex.q(1975,1);
estimEnd = datex.q(2014,4);
estimSpan = datex.span(estimStart, estimEnd);

meta = base.Meta( ...
    endogenousNames=["DOM_GDP", "DOM_CPI", "STN"], ...
    exogenousNames="Oil", ...
    order=4, ...
    intercept=true, ...
    estimationSpan=estimSpan, ...
    ...
    identificationHorizon=12, ...
    shockNames=["DEM", "SUP", "POL"] ...
);

dataH = base.DataHolder(meta, inputTbl);

estimatorR = base.estimator.NormalWishart(meta);


modelR = base.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
);


modelR.initialize();
infoR = modelR.presample(100);


%% Identify a SVAR using Cholesky with reordering 
%
% * Use Cholesky as if the endogenous variables were ordered in a different
% way than in meta
% * If a certain trailing portion of the order follows the meta order, you can
% omit that part


identChol = base.identifier.Cholesky(order=["DOM_CPI", "DOM_GDP", "STN"]);

% Equivalent to
% identChol = identifier.Cholesky(order=["DOM_CPI"]);

modelS0 = base.Structural(reducedForm=modelR, identifier=identChol);


modelS0

modelS0.initialize();
info0 = modelS0.presample(100);

modelS0.Presampled{1}.D
modelS0.Presampled{2}.D


respTbl0 = modelS0.simulateResponses(includeInitial=false);
respTbl0 = tablex.apply(respTbl0, extremesFunc);
respTbl0 = tablex.flatten(respTbl0);

respTbl0



%% Create conditional forecast assumptions 

fcastStart = datex.shift(estimEnd, 1);
fcastEnd = datex.shift(estimEnd, 12);
fcastSpan = datex.span(fcastStart, fcastEnd);
initStart = datex.shift(fcastStart, -modelS0.Meta.Order);


% Create empty table templates for conditioning data and a conditioning plan
% [condDataTbl0, planTbl0] = tablex.forConditional(modelS0, fcastSpan);
% 
% condDataTbl0
% planTbl0
% 
% % Populate the conditions table with some values
% condDataTbl0{datex("2015-Q4"), "DOM_GDP"} = -1.5;
% condDataTbl0{datex("2016-Q4"), "DOM_CPI"} = 5.5;
% condDataTbl0{datex("2016-Q3"), "STN"} = 5.1;
% 
% condDataTbl0{:, "Oil"} = inputTbl{end, "Oil"};
% tablex.toFile(condDataTbl0, "condDataTbl.xlsx")
% 
% planTbl0{datex("2015-Q4"), "DOM_GDP"} = "DEM POL";
% planTbl0{datex("2016-Q4"), "DOM_CPI"} = "DEM SUP";
% planTbl0{datex("2016-Q3"), "STN"} = "POL";
% tablex.toFile(planTbl0, "planTbl.xlsx");


%% Run across-the-board vs selective conditions forecasts 


condDataTbl = tablex.fromFile("tables/condDataTbl.xlsx");
planTbl = tablex.readPlan("tables/planTbl.xlsx");


% Run an unconditional forecast and calculate contributions starting at the
% beginning of the forecast

[uncFcastTbl1, uncFcastContribTbl1] = modelS0.forecast( ...
    fcastSpan, ...
    contributions=true ...
);


% Run an unconditional forecast and calculate contributions starting at the
% beginning of the historical (estimation) span


% Calculate the contributions on the estimation span
histContribTbl = modelS0.calculateContributions();

[uncFcastTbl2, uncFcastContribTbl2] = modelS0.forecast( ...
    fcastSpan, ...
    contributions=true, ...
    precontributions=histContribTbl ...
);


% Run a conditional forecast and calculate contributions starting at the
% beginning of the forecast span

[condFcastTbl1, condFcastContribTbl1] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=condDataTbl, ...
    plan=[] ...
);

[condFcastTbl2, condFcastContribTbl2] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=condDataTbl, ...
    plan=planTbl ...
);

condFcastPrctilesTbl1 = tablex.apply(condFcastTbl1, prctilesFunc);
condFcastPrctilesTbl2 = tablex.apply(condFcastTbl2, prctilesFunc);



% Run a conditional forecast and calculate contributions starting at the
% beginning of the forecast span

[condFcastTbl1, condFcastContribTbl1] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=condDataTbl, ...
    plan=[], ...
    contributions=true ...
);


% Run a conditional forecast and calculate contributions starting at the
% beginning of the historical (estimation) span

[condTbl2, condContTbl2] = modelS0.conditionalForecast( ...
    fcastSpan, ...
    conditions=condDataTbl, ...
    plan=[], ...
    contributions=true, ...
    precontributions=histContribTbl ...
);


% %% Visualize conditional forecasts 
% %
% 
% plotSettings = { ...
%    {"color"}, {defaultColors(2,:); defaultColors(1,:); defaultColors(2,:)},  ...
%    {"lineStyle"}, {":";"-";":"}, ...
% };
% 
% ch = visual.Chartpack( ...
%     span=datex.span(initStart, fcastEnd), ...
%     namesToPlot=[modelS0.Meta.EndogenousNames, modelS0.Meta.ShockNames], ...
%     plotSettings=plotSettings ...
% );
% 
% ch.Captions = "Across-the-board conditional forecast";
% ch.plot(condPrctilesTbl1);
% 
% ch.Captions = "Selective conditional forecast";
% % ch.plot(condPrctilesTbl2);
% 
% 
% %% Calculate median contributions, merge with history 
% 
% histContribMedianTbl = tablex.apply(histContTbl, medianFunc);
% 
% condContribMedianTbl1 = tablex.apply(condContTbl1, medianFunc);
% 
% condContribMedianTbl2 = tablex.apply(condContTbl2, medianFunc);
% 
% 
% % Merge history and conditional forecast contributions
% 
% allContribMedianTbl = tablex.merge( ...
%     histContribMedianTbl, ...
%     condContribMedianTbl2 ...
% );
% 
% 
% %% Visualize contributions 
% 
% legendEntries = tablex.getHigherDims(allContribMedianTbl, 3);
% 
% plotFunc = @(tbl, name, span) {
%     tablex.plot(tbl, name, periods=span, plotFunc=@bar, dims={1:3})
%     tablex.plot(tbl, name, periods=span, dims={4}, plotSettings={"lineWidth", 4})
%     tablex.plot(tbl, name, periods=span, dims={5}, plotSettings={"lineWidth", 4})
%     title(name, interpreter="none")
% };
% 
% 
% % Create three figures:
% % Fig 1: Forecast span, no precontributions
% % Fig 2: Forecast span, including precontributions
% % Fig 3: Entire span (history & forecast)
% 
% fig1 = figure(name="Contributions with no precontributions");
% fig2 = figure(name="Contributions including precontributions");
% fig3 = figure(name="Contributions, all history and forecast");
% 
% 
% % Loop over and plot the endogenous names
% 
% for i = 1 : 3
% 
%     name = modelS0.Meta.EndogenousNames(i);
% 
%     figure(fig1);
%     subplot(2, 2, i);
%     hold on;
%     plotFunc(condContribMedianTbl1, name, fcastSpan);
%     legend(legendEntries);
% 
%     figure(fig2);
%     subplot(2, 2, i);
%     hold on;
%     plotFunc(allContribMedianTbl, name, fcastSpan);
%     legend(legendEntries);
% 
%     figure(fig3);
%     subplot(2, 2, i);
%     hold on;
%     plotFunc(allContribMedianTbl, name, Inf);
%     xline(fcastSpan(1)-0.5, lineWidth=3);
%     legend([legendEntries, "Start of forecast"]);
% 
% end
% 
% 

