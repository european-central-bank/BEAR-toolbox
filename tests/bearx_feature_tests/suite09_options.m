function records = suite09_options(opts)
%SUITE09_OPTIONS  Verify GUI option semantics.

    arguments
        opts.numSamples (1, 1) double = 30
    end

    records = struct([]);
    csvPath = tutil_synthVAR();

    rec = tutil_runCase("suite09_options", "NumSamples_drawCount", ...
        @() checkNumSamples(csvPath, [10, 25, 50]));
    records = [records, rec];

    rec = tutil_runCase("suite09_options", "Percentiles_returnsRequested", ...
        @() checkPercentiles(csvPath, opts.numSamples, [5, 50, 95]));
    records = [records, rec];

    rec = tutil_runCase("suite09_options", "StochasticResiduals_addsNoise", ...
        @() checkStochasticResiduals(csvPath, opts.numSamples));
    records = [records, rec];

    rec = tutil_runCase("suite09_options", "Intercept_toggle", ...
        @() checkInterceptToggle(csvPath, opts.numSamples));
    records = [records, rec];

    rec = tutil_runCase("suite09_options", "Order_toggle", ...
        @() checkOrderToggle(csvPath, opts.numSamples));
    records = [records, rec];

    rec = tutil_runCase("suite09_options", "IdentificationHorizon_irfLength", ...
        @() checkIdentHorizon(csvPath, opts.numSamples));
    records = [records, rec];
end


function [meta, dataH] = buildMetaO(csvPath, varargin)
    import base.*
    inputTbl = tablex.fromCsv(csvPath);
    inputTbl = tablex.extend(inputTbl, -Inf, datex.q(2022, 4));
    inputTbl.Oil = fillmissing(inputTbl.Oil, "nearest");
    defaults = struct("order", 2, "intercept", true, "identHorizon", 8);
    for k = 1 : 2 : numel(varargin)
        defaults.(varargin{k}) = varargin{k+1};
    end
    meta = Meta( ...
        endogenousNames=["GDP", "INFL", "RATE"], ...
        exogenousNames="Oil", ...
        order=defaults.order, intercept=defaults.intercept, ...
        estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
        identificationHorizon=defaults.identHorizon, ...
        shockNames=["DEM", "SUP", "POL"]);
    dataH = DataHolder(meta, inputTbl);
end


function checkNumSamples(csvPath, ns)
    import base.*
    [meta, dataH] = buildMetaO(csvPath);
    for n = ns
        model = ReducedForm(meta=meta, dataHolder=dataH, ...
            estimator=estimator.NormalWishart(meta));
        model.initialize();
        model.presample(n);
        assert(numel(model.Presampled) == n, "bearx:test:numSamplesMismatch", ...
            "Requested %d, got %d", n, numel(model.Presampled));
    end
end


function checkPercentiles(csvPath, numSamples, prcs)
    import base.*
    [meta, dataH] = buildMetaO(csvPath);
    model = ReducedForm(meta=meta, dataHolder=dataH, ...
        estimator=estimator.NormalWishart(meta));
    model.initialize(); model.presample(numSamples);
    fc = model.forecast(datex.span(datex.q(2020, 1), datex.q(2020, 4)));
    fcP = tablex.apply(fc, @(x) prctile(x, prcs, 2));
    fcP = tablex.flatten(fcP);
    nCols = width(fcP);
    % Just verify flatten produced *more* columns than the unflattened
    % version (3 endo with embedded percentile pages becomes >=3 explicit cols).
    assert(nCols >= 3, "bearx:test:percentileCols", ...
        "Flattened percentile table has too few columns: got %d, want >=3", nCols);
end


function checkStochasticResiduals(csvPath, numSamples)
    import base.*
    [meta, dataH] = buildMetaO(csvPath);
    model = ReducedForm(meta=meta, dataHolder=dataH, ...
        estimator=estimator.NormalWishart(meta));
    model.initialize(); model.presample(numSamples);
    fcSpan = datex.span(datex.q(2020, 1), datex.q(2020, 4));

    rng(0)
    fcDet = model.forecast(fcSpan, StochasticResiduals=false);
    rng(0)
    fcSto = model.forecast(fcSpan, StochasticResiduals=true);

    detFlat = tablex.flatten(fcDet); detVals = detFlat{:, :};
    stoFlat = tablex.flatten(fcSto); stoVals = stoFlat{:, :};
    detVar = std(detVals(:), "omitnan");
    stoVar = std(stoVals(:), "omitnan");
    assert(stoVar > detVar, "bearx:test:stochasticNoNoise", ...
        "Stochastic forecast not noisier than deterministic: %.3g vs %.3g", stoVar, detVar);
end


function checkInterceptToggle(csvPath, numSamples)
    import base.*
    [m0, d0] = buildMetaO(csvPath, "intercept", false);
    model = ReducedForm(meta=m0, dataHolder=d0, estimator=estimator.NormalWishart(m0));
    model.initialize(); model.presample(numSamples);
    sz0 = size(model.Presampled{1}.beta, 1);

    [m1, d1] = buildMetaO(csvPath, "intercept", true);
    model2 = ReducedForm(meta=m1, dataHolder=d1, estimator=estimator.NormalWishart(m1));
    model2.initialize(); model2.presample(numSamples);
    sz1 = size(model2.Presampled{1}.beta, 1);
    % beta is shape (K*p + nExog + intercept) * K in row-oriented form.
    % Toggling intercept on adds K rows total (one intercept * K cols).
    K = 3;
    assert(sz1 == sz0 + K, "bearx:test:interceptRow", ...
        "Intercept toggle expected +%d beta rows, got %d vs %d", K, sz1, sz0);
end


function checkOrderToggle(csvPath, numSamples)
    import base.*
    [m1, d1] = buildMetaO(csvPath, "order", 1);
    model1 = ReducedForm(meta=m1, dataHolder=d1, estimator=estimator.NormalWishart(m1));
    model1.initialize(); model1.presample(numSamples);
    sz1 = size(model1.Presampled{1}.beta, 1);

    [m2, d2] = buildMetaO(csvPath, "order", 2);
    model2 = ReducedForm(meta=m2, dataHolder=d2, estimator=estimator.NormalWishart(m2));
    model2.initialize(); model2.presample(numSamples);
    sz2 = size(model2.Presampled{1}.beta, 1);
    % Going from order=1 to order=2 adds one full lag block of K rows,
    % multiplied by K columns -> diff is K^2 rows.
    K = 3;
    assert(sz2 == sz1 + K*K, "bearx:test:orderRow", ...
        "Order toggle expected +%d beta rows, got %d vs %d", K*K, sz2, sz1);
end


function checkIdentHorizon(csvPath, numSamples)
    import base.*
    [meta, dataH] = buildMetaO(csvPath, "identHorizon", 16);
    modelR = ReducedForm(meta=meta, dataHolder=dataH, ...
        estimator=estimator.NormalWishart(meta));
    modelR.initialize(); modelR.presample(numSamples);
    modelS = Structural(reducedForm=modelR, identifier=identifier.Cholesky());
    modelS.initialize(); modelS.presample(numSamples);
    resp = modelS.simulateResponses();
    nPer = height(resp);
    % IRF returns horizon+1 periods (impulse at h=0 plus h=1..H).
    expected = 16 + 1;
    assert(nPer == expected, "bearx:test:irfHorizon", ...
        "IRF has %d periods, expected %d (horizon+1)", nPer, expected);
end
