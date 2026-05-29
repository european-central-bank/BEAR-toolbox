
clear
clear classes
addpath ../bear


% uxFilePath = "BEAR6_UX.xlsx";
% excelUX = bear6.ExcelUX(filePath=uxFilePath);
% excelUX.readInputData();

% config = excelUX.Config;
% json.write(config, "testConfig.json");

configStruct = json.read("testConfig.json");
config = bear6.Config(configStruct);

inputTbx = tablex.fromCsv(config.DataSource_FilePath);


startTime = datetime();

rng(0);


percentiles = double(regexp(string(config.Tasks_Percentiles{2}), "\W+", "split"));
numPercentiles = numel(percentiles);


prctileFunc = @(x) prctile(x, percentiles, 2);
firstFunc = @(x) x(:, 1, :, :, :);
medianFunc = @(x) median(x, 2);
flatFunc = @(x) x(:, :);


meta = model.Meta( ...
    endogenous=config.Meta_EndogenousConcepts, ...
    units=config.Meta_Units, ...
    exogenous=config.Meta_ExogenousNames, ...
    order=config.Meta_Order, ...
    intercept=config.Meta_HasIntercept, ...
    estimationSpan=config.Meta_EstimationSpan, ...
    ...
    identificationHorizon=config.Meta_IdentificationHorizon, ...
    shockConcepts=config.Meta_ShockConcepts ...
);


dataH = model.DataHolder(meta, inputTbx);

estimatorR = estimator.(config.Estimator_Name)( ...
    meta, ...
    config.Estimator_Settings{:} ...
);

minnesotaD = dummies.Minnesota(exogenousLambda=30);

modelR = model.ReducedForm( ...
    meta=meta ...
    , dataHolder=dataH ...
    , estimator=estimatorR ...
    , dummies={minnesotaD} ...
    , stabilityThreshold=Inf ...
);

% modelR.initialize();
% modelR.presample(100);


% fcastStart = datex.shift(modelR.Meta.EstimationEnd, -10);
% fcastEnd = datex.shift(modelR.Meta.EstimationEnd, 0);
% fcastSpan = datex.span(fcastStart, fcastEnd);
% 
% fcastTbx = modelR.forecast(fcastSpan);
% residTbx = modelR.calculateResiduals();


id = identifier.Cholesky();

% 
% id = identifier.Custom( ...
%     exact=config.identifier.settings.exact, ...
%     verifiable=config.identifier.settings.verifiable ...
% );
% 

modelS = model.Structural( ...
    reducedForm=modelR, ...
    identifier=id ...
);


modelS.initialize()
modelS.presample(100);

fcastStart = datex.shift(modelS.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelS.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

f = modelS.forecast(fcastSpan);

u = modelS.estimateResiduals();
e = modelS.estimateShocks();
s = modelS.simulateResponses();

sp = tablex.apply(s, prctileFunc);
sp = tablex.flatten(sp);

ch = visual.Chartpack( ...
    span=tablex.span(sp), ...
    namesToPlot=tablex.names(sp), ...
    captions="Shock Responses" ...
);

% [f, p] = ch.plot(sp);


testStrings = [
    "abs($SHKRESP(1, 'DOM_GDP', 'POL')) > 0"
    "$SHKEST('2014-Q1', 'DEM') > 0.4"
    "$SHKCONT('2010-Q3', 'DOM_CPI', 'SUP') > 0.1"
]

id2 = identifier.Verifiables(testStrings);

modelS = model.Structural( ...
    reducedForm=modelR, ...
    identifier=id2 ...
);


modelS.initialize()
% info = modelS.presample(100);
info = modelS.presample(5);

e = modelS.estimateShocks();
s = modelS.simulateResponses();
c = modelS.breakdown();
f = modelS.forecast(fcastSpan);
v = modelS.calculateFEVD();

cm = tablex.apply(c, medianFunc);
cm = tablex.apply(cm, flatFunc);

vm = tablex.apply(v, medianFunc);
vm = tablex.apply(vm, flatFunc);

ch = visual.Chartpack( ...
    span=datex.span("2010-Q1", "2014-Q4"), ...
    namesToPlot=modelS.Meta.EndogenousNames, ...
    captions="Breakdown of historical observations (Median)", ...
    plotFunc=@bar ...
);
ch.plot(cm);
leg = tablex.getHigherDims(cm);
legend(leg{1});

return

longYXZ = modelS.getLongYXZ();
order = modelS.Meta.Order;


sample = modelS.Presampled{1};
draw = modelS.HistoryDrawer(sample);
A = draw.A{1};
C = draw.C{1};
D = sample.D;

lt = system.reshapeInit(longYXZ{1}(1:order, :));
X = longYXZ{2}(order+1:end, :);
X = [ones(160, 1), X];
E = modelS.estimateShocks4S(sample, longYXZ);
U = E * D;

yy = nan(160, 3);
X(:) = 0;
U(:) = 0;
for t = 1 : 160
    yy(t, :) = lt * A + X(t, :) * C + U(t, :);
    lt = [yy(t, :), lt(:, 1:end-3)];
end

y = longYXZ{1}(order+1:end, :);
ce = sum(c.DOM_GDP(:, :, 5), 3);

return

% vt.evaluateShortCircuit(vp)
vt.evaluateAll(vp)

id2.initialize(modelS)
s = cell(1, 50);
for i = 1 : 50
    s{i} = id2.Sampler();
end

return

fcastStart = datex.shift(modelR.Meta.EstimationEnd, -10);
fcastEnd = datex.shift(modelR.Meta.EstimationEnd, 0);
fcastSpan = datex.span(fcastStart, fcastEnd);

fcastTbx = modelR.forecast(fcastSpan);
residTbx = modelR.calculateResiduals();

respTbx = modelS.simulateResponses();
shockTbx = modelS.calculateShocks();
contTbx = modelS.calculateShockContributions();

return


fcastPctileTbx = tablex.apply(fcastTbx, prctileFunc);
writetimetable( ...
    fcastPctileTbx ...
    , "output/unconditionalForecast.csv" ...
);

residPctileTbx = tablex.apply(residTbx, prctileFunc);
writetimetable( ...
    residPctileTbx ...
    , "output/residuals.csv" ...
);


info = struct( ...
    startTime=startTime ...
    , endTime=datetime() ...
    , modelR=modelR ...
    , modelS=modelS ...
);

