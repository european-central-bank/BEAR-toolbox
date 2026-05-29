close all
clear
clear classes
rehash path
addpath ../bear

hist = tablex.fromCsv("exampleData.csv");
dataSpan = tablex.span(hist);
startData = dataSpan(1);
endData = dataSpan(end);

estimationStart = datex.shift(startData, 4);
estimationEnd = endData;
estimationSpan = datex.span(estimationStart, estimationEnd);

d1 = dummies.InitialObservations(lambda=2);
d2 = dummies.Minnesota(exogenousLambda=30);

endogenous = ["DOM_GDP", "DOM_CPI", "STN"];

metaR = meta.ReducedForm( ...
    endogenous=endogenous ...
    , order=4 ...
    , intercept=true ...
    , estimationSpan=estimationSpan ...
);


H = [1, 0, 0; 0, 1, 1; 0, -1, 1];

H = constable.new(rowNames=endogenous, columnNames=endogenous, initValue=0);
H{"DOM_GDP", "DOM_GDP"} = 1;
H{"DOM_CPI", ["DOM_CPI", "STN"]} = [1, 1];
H{"STN", ["DOM_CPI", "STN"]} = [-1, 1];

d3 = dummies.LongRun(lambda=100, constraints=H);

d4 = dummies.SumCoefficients(lambda=0.45);

longYXZ = metaR.getLongYXZ(hist, estimationSpan);

dummiesYLX1 = d1.generate(metaR, longYXZ);
dummiesYLX2 = d2.generate(metaR, longYXZ);
dummiesYLX3 = d3.generate(metaR, longYXZ);
dummiesYLX4 = d4.generate(metaR, longYXZ);

return

estimator = estimator.NormalWishart();

v0 = model.ReducedForm( ...
    meta=metaR ...
    , estimator=estimator ...
);

v1 = model.ReducedForm( ...
    meta=metaR ...
    , estimator=estimator ...
    , dummies={d1, d3, } ...
);


N = 1000;

rng(0);
v0.initialize(hist, estimSpan);
v0.presample(N);
v0.Estimator.SampleCounter

rng(0);
v1.initialize(hist, estimSpan);
v1.presample(N);
v1.Estimator.SampleCounter

return

opt = dummies.populateLegacyOptions(v.Dummies);
YLX = v.getDataYLX(hist, dataSpan);

%%%%obsolete block delete once LHS vars are created loaded elsewhere
opt.excelFile = "C://Git//BEAR-toolbox-6//tbx//replications//data_.xlsx"; %needed for location of lr priors
opt.priorsexogenous  = false; %set true if want to use individual priors for exo 
H = bear.loadH(struct('excelFile', opt.excelFile));

ds = dataSpan(1:meta.Order);
init_endo = nan(numel(ds), 0);
n = numel(meta.EndogenousItems);
for i = 1:numel(meta.EndogenousItems)
    item = meta.EndogenousItems{i};
    init_endo = [init_endo, item.getData(hist, ds, variant=1)];
end

init_exo = nan(numel(ds), 0);
m = numel(meta.ExogenousItems);
for i = 1:m
    item = meta.ExogenousItems{i};
    init_exo = [init_exo, item.getData(hist, ds, variant=1)];
end

for ii=1:n
    for jj=1:m
        priorexo(ii,jj) = opt.priorsexogenous;
        lambda4(ii,jj) = opt.lambda4;
    end
end
opt.lambda4 = lambda4;    
[arvar] = bear.arloop(YLX{1},isa(meta.ExogenousItems(end),"item.Constant"),meta.Order,n);
ar = ones(n,1)*opt.ar;

%%%%obsolete block end

[Ystar, LXstar] = dummy_to_YLX(YLX, init_endo, init_exo,meta.Order, opt, H , ar, arvar, priorexo);

disp(opt)

function [Ystar, LXstar] = dummy_to_YLX(YLX, init_endo, init_exo, order, opt, H, ar, arvar, priorexo)

Ystar = YLX{1};
LXstar = [YLX{2} YLX{3}];

n = size(init_endo,2);
m = size(init_exo,2);

if opt.scoeff
    [Ys, LXs ]  = test.get_scoeff_dummy(init_endo, n,m,order,opt.lambda6);
    Ystar = [Ystar;Ys];
    LXstar = [LXstar;LXs];
end

if opt.iobs
    [Yo, LXo ]  = test.get_iobs_dummy(init_endo,init_exo,order,opt.lambda7);
    Ystar = [Ystar;Yo];
    LXstar = [LXstar;LXo];
end

if opt.lrp
    [Yl, LXl ]  = test.get_lrp_dummy(init_endo,H, n,m,order,opt.lambda8);
    Ystar = [Ystar;Yl];
    LXstar = [LXstar;LXl];
end

if opt.prior == 51
    [Ym, LXm ]  = test.get_min_dummy(n,m,order,ar,arvar,opt.lambda1,opt.lambda3,opt.lambda4,priorexo);
    Ystar = [Ystar;Ym];
    LXstar = [LXstar;LXm];
end

end
