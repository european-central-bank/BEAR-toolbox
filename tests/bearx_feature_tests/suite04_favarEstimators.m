function records = suite04_favarEstimators(opts)
%SUITE04_FAVARESTIMATORS  One-step (5) + Two-step (10) factor-augmented BVARs.

    arguments
        opts.numSamples (1, 1) double = 30
    end

    records = struct([]);
    csvPath = tutil_synthFAVAR();

    onestep = ["FlatFAVAROnestep", "IndNormalWishartFAVAROnestep", ...
               "MinnesotaFAVAROnestep", "NormalDiffuseFAVAROnestep", ...
               "NormalWishartFAVAROnestep"];
    for k = 1 : numel(onestep)
        nm = onestep(k);
        rec = tutil_runCase("suite04_favar_1step", nm, ...
            @() runOnestep(csvPath, nm, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end

    twostep = ["BetaTVFAVAR", "CarrieroSVFAVAR", "CogleySargentSVFAVAR", ...
               "FlatFAVARTwostep", "GeneralTVFAVAR", ...
               "IndNormalWishartFAVARTwostep", "MinnesotaFAVARTwostep", ...
               "NormalDiffuseFAVARTwostep", "NormalWishartFAVARTwostep", ...
               "RandomInertiaSVFAVAR"];
    for k = 1 : numel(twostep)
        nm = twostep(k);
        rec = tutil_runCase("suite04_favar_2step", nm, ...
            @() runTwostep(csvPath, nm, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end
end


function runOnestep(csvPath, estimName, numSamples)
    import factorOnestep.*

    inputTbl = tablex.fromCsv(csvPath);
    % Onestep specifics (per test2b_factorOnestep tutorial):
    %   - intercept is NOT allowed (data are standardized internally)
    %   - single block named "main" auto-created from reducibleNames
    %   - one (or few) endo with many reducibles works best
    meta = Meta( ...
        endogenousNames="GDP", ...
        reducibleNames="R" + string(1:8), ...
        numFactors=2, ...
        order=2, ...
        estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
        identificationHorizon=8);
    dataH = DataHolder(meta, inputTbl);

    % Onestep estimator constructors take NO meta argument
    ctor = str2func("factorOnestep.estimator." + estimName);
    est = ctor();

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    model.presample(numSamples);

    assert(~isempty(model.Presampled), "bearx:test:noPresampled", "empty presampled");
end


function runTwostep(csvPath, estimName, numSamples)
    import factorTwostep.*

    inputTbl = tablex.fromCsv(csvPath);
    % Mirror test2a_factorTwostep tutorial pattern. SV/IndNW/Minnesota variants
    % require at least 2 endogenous (their samplers index endogenous(2)).
    needsMultiEndo = ["CarrieroSVFAVAR", "CogleySargentSVFAVAR", ...
        "IndNormalWishartFAVARTwostep", "MinnesotaFAVARTwostep", ...
        "NormalDiffuseFAVARTwostep", "NormalWishartFAVARTwostep"];
    if any(estimName == needsMultiEndo)
        endoNames = ["GDP", "INFL"];
    else
        endoNames = "GDP";
    end
    nRed = 8;
    blocks = repmat("main", 1, nRed);
    meta = Meta( ...
        endogenousNames=endoNames, ...
        reducibleNames="R" + string(1:nRed), ...
        reducibleBlocks=blocks, ...
        blockType="blocks", ...
        numFactors=struct("main", 2), ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
        identificationHorizon=8);
    dataH = DataHolder(meta, inputTbl);

    % Twostep estimator constructors take NO meta argument
    ctor = str2func("factorTwostep.estimator." + estimName);
    est = ctor();

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    model.presample(numSamples);

    assert(~isempty(model.Presampled), "bearx:test:noPresampled", "empty presampled");
end
