function results = regression_bug9(toolboxPath)
% regression_bug9 — Regression test for the Bug 9 patch
% (`+base/@Structural/conditionalForecast.m`: rebuild cfblocks per-unit).
%
% Three scenarios exercising base.Structural.conditionalForecast:
%   S1 — non-panel base BVAR (NumSeparableUnits = 1).
%   S2 — separable panel, shocks restricted to ONE unit per period.
%   S3 — separable panel, shocks in MULTIPLE units at the SAME period
%        (this is the case Bug 9 fixes).
%
% Usage (from BEARX-GUI-Examples/):
%   results = regression_bug9                                            % vs ../BEARX-Toolbox
%   results = regression_bug9('../BEARX-Toolbox-PATCHED')                % vs PATCHED
%
% Expected: 3 PASS on PATCHED, S1+S2 PASS / S3 FAIL on UNPATCHED.

    arguments
        toolboxPath (1,1) string = "../BEARX-Toolbox"
    end

    rootDir = pwd;
    tbxBear     = fullfile(toolboxPath, "tbx", "bear");
    tbxBearing  = fullfile(toolboxPath, "tbx", "bear", "bearing");
    assert(isfolder(tbxBear), "Toolbox not found at: %s", tbxBear);
    addpath(tbxBear,    "-end");
    addpath(tbxBearing, "-end");

    csvPath = fullfile(rootDir, "regression_data.csv");
    assert(isfile(csvPath), "Missing regression_data.csv next to this script.");

    scenarios = ["S1_nonPanel"; "S2_panelOneUnit"; "S3_panelMultiUnit"];
    status     = strings(3, 1);
    duration   = zeros(3, 1);
    identifier = strings(3, 1);
    message    = strings(3, 1);

    for k = 1 : numel(scenarios)
        fprintf("[%d/3] %s ... ", k, scenarios(k));
        t0 = tic;
        try
            switch scenarios(k)
                case "S1_nonPanel",       runS1(csvPath);
                case "S2_panelOneUnit",   runS2(csvPath);
                case "S3_panelMultiUnit", runS3(csvPath);
            end
            status(k) = "PASS";
            fprintf("PASS (%.1fs)\n", toc(t0));
        catch err
            status(k)     = "FAIL";
            identifier(k) = string(err.identifier);
            message(k)    = string(err.message);
            fprintf("FAIL — %s\n  %s\n", err.identifier, err.message);
        end
        duration(k) = toc(t0);
        close all;
    end

    results = table(scenarios, status, duration, identifier, message);

    fprintf("\n=== Summary ===\n");
    fprintf("PASS: %d / 3\n", sum(status == "PASS"));
    fprintf("FAIL: %d / 3\n", sum(status == "FAIL"));
    if all(status == "PASS")
        fprintf("\nBug 9 patch confirmed: fixes S3 without regressing S1/S2.\n");
    end
end


function runS1(csvPath)
% S1 — non-panel base BVAR + conditions-only forecast.
    import base.*

    inputTbl = tablex.fromCsv(csvPath);
    endo  = ["US_YER", "US_HICSA", "US_STN"];
    estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
    meta  = Meta(endogenousNames=endo, order=2, estimationSpan=estSpan);
    dataH = DataHolder(meta, inputTbl);
    est   = base.estimator.NormalWishart(meta);
    red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    red.initialize();
    red.presample(50);
    ident = identifier.Cholesky();
    str   = Structural(reducedForm=red, identifier=ident);
    str.initialize();
    str.presample(50);

    fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
    [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
    % Conditions on one variable, empty plan -> exercises the no-plan branch.
    condTbl{datex.q(2015,2), "US_YER"} = 124.5;
    fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
        exogenousFrom="conditions", includeInitial=false);
    assert(~isempty(fc), "S1 produced empty forecast");
end


function runS2(csvPath)
% S2 — 2-country separable panel, shocks restricted to ONE unit per period.
    import separable.*

    inputTbl = tablex.fromCsv(csvPath);
    endoConcepts  = ["YER", "HICSA", "STN"];
    shockConcepts = ["DEM", "SUP", "POL"];
    units = ["US", "EA"];
    estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
    meta  = Meta(endogenousConcepts=endoConcepts, shockConcepts=shockConcepts, ...
        units=units, order=2, estimationSpan=estSpan);
    dataH = DataHolder(meta, inputTbl);
    est   = separable.estimator.NormalWishartPanel(meta);
    red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    red.initialize();
    red.presample(50);
    ident = identifier.Cholesky();
    str   = Structural(reducedForm=red, identifier=ident);
    str.initialize();
    str.presample(50);

    fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
    [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
    % Shocks only in US for Q2, only in EA for Q3 — never simultaneous.
    condTbl{datex.q(2015,2), "US_STN"} = 5.0;
    planTbl{datex.q(2015,2), "US_STN"} = "DEM";
    condTbl{datex.q(2015,3), "EA_STN"} = 5.5;
    planTbl{datex.q(2015,3), "EA_STN"} = "DEM";
    fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
        exogenousFrom="conditions", includeInitial=false);
    assert(~isempty(fc), "S2 produced empty forecast");
end


function runS3(csvPath)
% S3 — 3-country separable panel, shocks in MULTIPLE units at the SAME period.
% This is the case Bug 9 fixes. Without the patch: crash in shocksim6:45.
    import separable.*

    inputTbl = tablex.fromCsv(csvPath);
    endoConcepts  = ["YER", "HICSA", "STN"];
    shockConcepts = ["DEM", "SUP", "POL"];
    units = ["US", "EA", "UK"];
    estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
    meta  = Meta(endogenousConcepts=endoConcepts, shockConcepts=shockConcepts, ...
        units=units, order=2, estimationSpan=estSpan);
    dataH = DataHolder(meta, inputTbl);
    est   = separable.estimator.NormalWishartPanel(meta);
    red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    red.initialize();
    red.presample(50);
    ident = identifier.Cholesky();
    str   = Structural(reducedForm=red, identifier=ident);
    str.initialize();
    str.presample(50);

    fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
    [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
    % Mirror SeparablePanel/master.m: same period, all 3 units.
    condTbl{datex.q(2015,3), "US_STN"} = 5.0;
    condTbl{datex.q(2015,3), "EA_STN"} = 5.5;
    condTbl{datex.q(2015,3), "UK_STN"} = 6.0;
    planTbl{datex.q(2015,3), "US_STN"} = "DEM POL";
    planTbl{datex.q(2015,3), "EA_STN"} = "DEM POL";
    planTbl{datex.q(2015,3), "UK_STN"} = "SUP POL";
    fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
        exogenousFrom="conditions", includeInitial=false);
    assert(~isempty(fc), "S3 produced empty forecast");
end
