function records = suite08_tasks(opts)
%SUITE08_TASKS  Smoke + semantic tests for the 8 GUI tasks.

    arguments
        opts.numSamples (1, 1) double = 40
    end

    records = struct([]);
    csvPath = tutil_synthVAR();
    outDir = fullfile(tutil_dataDir(), "task_outputs");
    if isfolder(outDir), rmdir(outDir, "s"); end
    mkdir(outDir);

    [meta, dataH] = buildMeta(csvPath);
    modelR = base.ReducedForm(meta=meta, dataHolder=dataH, ...
        estimator=base.estimator.NormalWishart(meta));
    modelR.initialize();
    modelR.presample(opts.numSamples);

    modelS = base.Structural(reducedForm=modelR, identifier=identifier.Cholesky());
    modelS.initialize();
    modelS.presample(opts.numSamples);

    fcastSpan = datex.span(datex.q(2020, 1), datex.q(2021, 4));

    rec = tutil_runCase("suite08_tasks", "ReducedFormEstimation", @() ...
        assert(numel(modelR.Presampled) == opts.numSamples, ...
            "bearx:test:badCount", "Wrong sample count"));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "StructuralEstimation", @() ...
        assert(numel(modelS.Presampled) == opts.numSamples, ...
            "bearx:test:badCount", "Wrong sample count"));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "ReducedFormForecast", @() ...
        checkRedForecast(modelR, fcastSpan));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "StructuralForecast", @() ...
        checkStructForecast(modelS, fcastSpan));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "ConditionalForecast_conditionsMet", @() ...
        checkConditional(modelS, fcastSpan));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "ShockResponses", @() ...
        checkResponses(modelS, meta));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "ShockContributions", @() ...
        checkContributions(modelS));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks", "FEVD", @() ...
        checkFEVD(modelS));
    records = [records, rec];

    rec = tutil_runCase("suite08_tasks_files", "SaveXLS", @() ...
        checkSaveTable(modelR, fcastSpan, outDir, "xlsx"));
    records = [records, rec];
    rec = tutil_runCase("suite08_tasks_files", "SaveCSV", @() ...
        checkSaveTable(modelR, fcastSpan, outDir, "csv"));
    records = [records, rec];
    rec = tutil_runCase("suite08_tasks_files", "SaveMAT", @() ...
        checkSaveTable(modelR, fcastSpan, outDir, "mat"));
    records = [records, rec];
end


function [meta, dataH] = buildMeta(csvPath)
    import base.*
    inputTbl = tablex.fromCsv(csvPath);
    inputTbl = tablex.extend(inputTbl, -Inf, datex.q(2022, 4));
    inputTbl.Oil = fillmissing(inputTbl.Oil, "nearest");
    meta = Meta( ...
        endogenousNames=["GDP", "INFL", "RATE"], ...
        exogenousNames="Oil", ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
        identificationHorizon=8, ...
        shockNames=["DEM", "SUP", "POL"]);
    dataH = DataHolder(meta, inputTbl);
end


function checkRedForecast(modelR, fcastSpan)
    % Use defaults: forecast(fcastSpan) - StochasticResiduals defaults to true.
    fc = modelR.forecast(fcastSpan);
    assert(~isempty(fc), "bearx:test:emptyForecast", "Empty reduced-form forecast");
end


function checkStructForecast(modelS, fcastSpan)
    fc = modelS.forecast(fcastSpan);
    assert(~isempty(fc), "bearx:test:emptyForecast", "Empty structural forecast");
end


function checkConditional(modelS, fcastSpan)
    [condTbl, planTbl] = tablex.forConditional(modelS, fcastSpan); %#ok<ASGLU>
    condDate = datex.q(2020, 2);
    condTbl{condDate, "GDP"} = 1.0;

    fc = modelS.conditionalForecast(fcastSpan, conditions=condTbl, plan=[]);
    assert(~isempty(fc), "bearx:test:emptyCondForecast", "Empty conditional forecast");

    % Verify median forecast meets the imposed condition
    medianFc = tablex.apply(fc, @(x) median(x, 2));
    actual = medianFc{condDate, "GDP"};
    if iscell(actual), actual = actual{1}; end
    assert(abs(actual - 1.0) < 1e-3, "bearx:test:condNotMet", ...
        "Conditioned value not met: expected 1.0, got %.4g", actual);
end


function checkResponses(modelS, meta)
    resp = modelS.simulateResponses();
    assert(~isempty(resp), "bearx:test:emptyIRF", "Empty IRF table");
    sz = size(modelS.Presampled{1}.D);
    assert(all(sz == [numel(meta.EndogenousNames), numel(meta.ShockNames)]), ...
        "bearx:test:badIRFshape", "IRF D shape mismatch");
end


function checkContributions(modelS)
    cont = modelS.calculateContributions();
    assert(~isempty(cont), "bearx:test:emptyContribs", "Empty contributions");
end


function checkFEVD(modelS)
    % Try calculateFEVD first (current API), fall back to legacy fevd.
    try
        fevdTbl = modelS.calculateFEVD();
    catch err1
        if err1.identifier == "MATLAB:noSuchMethodOrField"
            try
                fevdTbl = modelS.fevd();
            catch err2
                error("bearx:test:noFEVD", ...
                    "Neither calculateFEVD nor fevd exists: %s / %s", ...
                    err1.message, err2.message);
            end
        else
            rethrow(err1);
        end
    end
    assert(~isempty(fevdTbl), "bearx:test:emptyFEVD", "Empty FEVD");
end


function checkSaveTable(modelR, fcastSpan, outDir, fmt)
    fc = modelR.forecast(fcastSpan);
    fname = fullfile(outDir, "redForecast." + fmt);
    if strcmpi(fmt, "mat")
        save(fname, "fc");
    else
        % tablex.toFile dispatches on extension (xlsx vs csv)
        tablex.toFile(fc, fname);
    end
    assert(isfile(fname), "bearx:test:fileMissing", ...
        "Expected file not written: %s", fname);
    fi = dir(fname);
    assert(fi.bytes > 0, "bearx:test:fileEmpty", "Output file is empty: %s", fname);
end
