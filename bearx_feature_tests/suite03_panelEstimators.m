function records = suite03_panelEstimators(opts)
%SUITE03_PANELESTIMATORS  Separable (4) + Cross (2) panel estimators.

    arguments
        opts.numSamples (1, 1) double = 50
    end

    records = struct([]);
    csvPath = tutil_synthPanel();

    sepCases = ["NormalWishartPanel", "MeanOLSPanel", "ZellnerHongPanel", "HierarchicalPanel"];
    for k = 1 : numel(sepCases)
        nm = sepCases(k);
        rec = tutil_runCase("suite03_panel_sep", nm, ...
            @() runSeparable(csvPath, nm, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end

    crossCases = ["StaticCrossPanel", "DynamicCrossPanel"];
    for k = 1 : numel(crossCases)
        nm = crossCases(k);
        rec = tutil_runCase("suite03_panel_cross", nm, ...
            @() runCross(csvPath, nm, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end
end


function runSeparable(csvPath, estimName, numSamples)
    import separable.*

    inputTbl = tablex.fromCsv(csvPath);
    meta = Meta( ...
        endogenousConcepts=["YER", "HICSA", "STN"], ...
        units=["US", "EA", "UK"], ...
        exogenousNames="Oil", ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.q(1995, 3), datex.q(2019, 4)), ...
        identificationHorizon=8, ...
        shockConcepts=["DEM", "SUP", "POL"]);
    dataH = DataHolder(meta, inputTbl);

    ctor = str2func("separable.estimator." + estimName);
    est = ctor(meta);

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    model.presample(numSamples);

    assert(~isempty(model.Presampled), "bearx:test:noPresampled", "empty presampled");
end


function runCross(csvPath, estimName, numSamples)
    import cross.*

    inputTbl = tablex.fromCsv(csvPath);
    meta = Meta( ...
        endogenousConcepts=["YER", "HICSA", "STN"], ...
        units=["US", "EA", "UK"], ...
        exogenousNames="Oil", ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.q(1995, 3), datex.q(2019, 4)), ...
        identificationHorizon=8, ...
        shockConcepts=["DEM", "SUP", "POL"]);
    dataH = DataHolder(meta, inputTbl);

    ctor = str2func("cross.estimator." + estimName);
    est = ctor(meta);

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    model.presample(numSamples);

    assert(~isempty(model.Presampled), "bearx:test:noPresampled", "empty presampled");
end
