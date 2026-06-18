

close all
clear
clear classes
rehash path
addpath ../bear

rng(0);

% pctileFunc = @(x) prctile(x, [5, 50, 95], 2);

% master = bear6.run(configStruct=configStruct);
% config = master.Config;

config = struct();

config.data = struct( ...
    "format", "csv", ...
    "source", "exampleData.csv" ...
);

config.meta = struct( ...
    "endogenous", ["DOM_GDP", "DOM_CPI", "STN"], ...
    "exogenous", ["Oil"], ...
    "order", 4, ...
    "estimationStart", "1975-Q1", ...
    "estimationEnd", "2014-Q4", ...
    "intercept", true ...
);

% histLegacy = tablex.fromCsv("exampleDataLegacy.csv", dateFormat="legacy");
% hist = tablex.fromCsv("exampleData.csv");

inputTbx = bear6.readInputData(config.data);

dataSpan = tablex.span(inputTbx);
estimSpan = dataSpan;

metaR = meta.ReducedForm( ...
    endogenous=config.meta.endogenous ...
    , exogenous=config.meta.exogenous ...
    , order=config.meta.order ...
    , intercept=config.meta.intercept ...
    , estimationSpan=datex.span(config.meta.estimationStart, config.meta.estimationEnd) ...
);

dataH = model.DataHolder(metaR, inputTbx);

estimator = estimator.Ordinary(metaR);

dummy = dummies.Minnesota(exogenousLambda=30);

modelR = model.ReducedForm( ...
    meta=metaR ...
    , dataHolder=dataH ...
    , estimator=estimator ...
    , dummies={dummy} ...
    , stabilityThreshold=Inf ...
)

modelR.initialize();
modelR.presample(100);

fcastStart = datex.shift(modelR.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastTbx = modelR.forecast(fcastSpan);
residTbx = modelR.calculateResiduals();

metaS = meta.Structural(metaR, identificationHorizon=20);

id = identifier.Triangular(stdVec=1);

% 
% id = identifier.Custom( ...
%     exact=config.identifier.settings.exact, ...
%     verifiable=config.identifier.settings.verifiable ...
% );
% 


modelS = model.Structural(meta=metaS, reducedForm=modelR, identifier=id);
modelS.initialize()
modelS.presample(100);


% U = E * D
% cov U = E[ U' * U ] = E[ D' * E' * E * D ] = E[ D' * D ]


% % modelR.initialize(hist, estimSpan);
% s.initialize(hist, estimSpan);
% s.presample(100);
% 
% shockSpan = datex.span(datex.q(1,1), datex.q(10,4));
% 
% fevd = s.fevd(shockSpan);
% 
% shockTbx = s.simulateShocks(shockSpan);
% shockPctileTbx = tablex.apply(shockTbx, pctileFunc);
% tiledlayout(3, 3);
% time = 0 : numel(shockPctileTbx.Time)-1;
% for n = ["DOM_GDP", "DOM_CPI", "STN"]
%     for i = 1 : 3
%         shockName = s.Meta.ShockNames(i);
%         nexttile();
%         hold on
%         data = shockPctileTbx.(n)(:, :, i);
%         h = plot(time, data);
%         set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.3, 0.6, 0.6]);
%         title(n + " <-- " + shockName, interpreter="none");
%     end
% end
% 
% return
% 
% N = 10000;
% 
% disp("Presampling...")
% modelR.presample(N);
% modelR.Estimator.SampleCounter
% 
% amean = s.asymptoticMean();
% 
% endHist = estimSpan(end);
% % startForecast = datex.shift(endHist, -11);
% % endForecast = datex.shift(endHist, 0);
% startForecast = datex.shift(endHist, 1);
% endForecast = datex.shift(endHist, 100);
% forecastSpan = datex.span(startForecast, endForecast);
% 
% rng(0);
% disp("Forecasting...")
% fcast = s.forecast(hist, forecastSpan);
% clippedHist = tablex.clip(hist, endHist, endHist);
% 
% 
% fcastPctiles = tablex.apply(fcast, pctileFunc);
% fcastPctiles = tablex.merge(clippedHist, fcastPctiles);
% 
% fcastMean = tablex.apply(fcast, @(x) mean(x, 2));
% fcastMean = tablex.merge(clippedHist, fcastMean);
% 
% tiledlayout(2, 2);
% for n = ["DOM_GDP", "DOM_CPI", "STN"]
%     nexttile();
%     hold on
%     h = tablex.plot(fcastPctiles, n);
%     set(h, {"lineStyle"}, {":"; "-"; ":"}, "lineWidth", 3, "color", [0.5, 0.8, 0.8]);
%     h = tablex.plot(hist, n);
%     set(h, color="black", lineWidth=2);
% end
% 
