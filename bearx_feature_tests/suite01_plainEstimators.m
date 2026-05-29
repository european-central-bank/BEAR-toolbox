function records = suite01_plainEstimators(opts)
%SUITE01_PLAINESTIMATORS  Smoke-test every plain BVAR estimator (base.*).

    arguments
        opts.numSamples (1, 1) double = 50
    end

    records = struct([]);
    csvPath = tutil_synthVAR();

    estimNames = ["NormalWishart", "Minnesota", "IndNormalWishart", ...
                  "NormalDiffuse", "Flat", "Ordinary"];

    for k = 1 : numel(estimNames)
        nm = estimNames(k);
        rec = tutil_runCase("suite01_plain", nm, @() runOne(csvPath, nm, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end
end


function runOne(csvPath, estimName, numSamples)
    import base.*

    inputTbl = tablex.fromCsv(csvPath);
    estimStart = datex.q(1990, 3);             % skip 2 obs for VAR(2) init
    estimEnd   = datex.q(2019, 4);
    meta = Meta( ...
        endogenousNames=["GDP", "INFL", "RATE"], ...
        exogenousNames="Oil", ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(estimStart, estimEnd), ...
        identificationHorizon=8, ...
        shockNames=["DEM", "SUP", "POL"]);

    dataH = DataHolder(meta, inputTbl);

    ctor = str2func("base.estimator." + estimName);
    est = ctor(meta);

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    info = model.presample(numSamples); %#ok<NASGU>

    assert(numel(model.Presampled) == numSamples, ...
        "bearx:test:sampleCount", ...
        "Expected %d presampled draws, got %d", numSamples, numel(model.Presampled));
    assert(~isempty(model.Presampled{1}.beta), ...
        "bearx:test:emptyBeta", "Presampled{1}.beta is empty");
end
