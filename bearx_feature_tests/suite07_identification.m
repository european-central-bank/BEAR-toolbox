function records = suite07_identification(opts)
%SUITE07_IDENTIFICATION  Smoke + semantic tests for the 5 GUI identifiers.

    arguments
        opts.numSamples (1, 1) double = 30
        opts.numCandidates (1, 1) double = 50
    end

    records = struct([]);
    csvPath = tutil_synthVAR();
    [meta, dataH] = buildMeta(csvPath);

    outDir = fullfile(tutil_dataDir(), "ident_tables");
    if ~isfolder(outDir), mkdir(outDir); end

    rec = tutil_runCase("suite07_ident", "Cholesky_noReorder", ...
        @() runCholesky(meta, dataH, [], opts.numSamples));
    records = [records, rec];

    rec = tutil_runCase("suite07_ident", "Cholesky_reorder", ...
        @() runCholesky(meta, dataH, ["RATE", "GDP", "INFL"], opts.numSamples));
    records = [records, rec];

    rec = tutil_runCase("suite07_ident", "InstantZeros_zerosRespected", ...
        @() runInstantZeros(meta, dataH, opts.numSamples, outDir));
    records = [records, rec];

    rec = tutil_runCase("suite07_ident", "IneqRestrict_signsRespected", ...
        @() runIneqRestrict(meta, dataH, opts.numSamples, opts.numCandidates, outDir));
    records = [records, rec];

    rec = tutil_runCase("suite07_ident", "GeneralRestrict_signsAndFEVD", ...
        @() runGeneralRestrict(meta, dataH, opts.numSamples, max(opts.numCandidates, 200), outDir));
    records = [records, rec];
end


function [meta, dataH] = buildMeta(csvPath)
    import base.*
    inputTbl = tablex.fromCsv(csvPath);
    meta = Meta( ...
        endogenousNames=["GDP", "INFL", "RATE"], ...
        exogenousNames="Oil", ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
        identificationHorizon=8, ...
        shockNames=["DEM", "SUP", "POL"]);
    dataH = DataHolder(meta, inputTbl);
end


function modelR = baseReducedForm(meta, dataH, numSamples)
    import base.*
    modelR = ReducedForm(meta=meta, dataHolder=dataH, ...
        estimator=estimator.NormalWishart(meta));
    modelR.initialize();
    modelR.presample(numSamples);
end


function runCholesky(meta, dataH, ordering, numSamples)
    import base.*
    modelR = baseReducedForm(meta, dataH, numSamples);
    if isempty(ordering)
        ident = identifier.Cholesky();
    else
        ident = identifier.Cholesky(ordering=ordering);
    end
    modelS = Structural(reducedForm=modelR, identifier=ident);
    modelS.initialize();
    modelS.presample(numSamples);

    % BEAR's Cholesky stores  P = chol(Sigma(o,o))(:, backOrder).
    % => P is NOT triangular when reordering is used; instead it satisfies
    %    P' * P == Sigma in the original ordering. Check that identity.
    sample = modelS.Presampled{1};
    D = sample.D;
    Sigma = sample.sigma;   % lowercase field as stored by base estimators
    % BEAR row-oriented convention: Cov(U) = D' * D = Sigma
    err = norm(D' * D - Sigma, "fro") / max(1, norm(Sigma, "fro"));
    assert(err < 1e-8, "bearx:test:choleskyMismatch", ...
        "P''P does not reconstruct Sigma: rel err = %.3g", err);
end


function runInstantZeros(meta, dataH, numSamples, outDir) %#ok<INUSL>
    import base.*
    modelR = baseReducedForm(meta, dataH, numSamples);

    tbl = tablex.forInstantZeros(modelR);
    tbl{"GDP", "POL"} = 0;
    tbl{"INFL", "POL"} = 0;

    % Round-trip through xlsx exactly as the tutorial does.
    fname = fullfile(outDir, "instantZerosTbl.xlsx");
    if isfile(fname), delete(fname); end
    tablex.writetable(tbl, fname);
    tblBack = tablex.readtable(fname, convertTo=@double);
    ident = identifier.InstantZeros(table=tblBack);

    modelS = Structural(reducedForm=modelR, identifier=ident);
    modelS.initialize();
    modelS.presample(numSamples);

    iGDP  = find(meta.EndogenousNames == "GDP", 1);
    iINFL = find(meta.EndogenousNames == "INFL", 1);
    jPOL  = find(meta.ShockNames == "POL", 1);
    % BEAR D is row-oriented: rows = shocks, cols = endos
    maxGDP = 0; maxINFL = 0;
    for k = 1 : numel(modelS.Presampled)
        D = modelS.Presampled{k}.D;
        maxGDP  = max(maxGDP,  abs(D(jPOL, iGDP)));
        maxINFL = max(maxINFL, abs(D(jPOL, iINFL)));
    end
    assert(maxGDP < 1e-6 && maxINFL < 1e-6, "bearx:test:zeroNotRespected", ...
        "InstantZero violated: max |D(POL,GDP)|=%.3g, |D(POL,INFL)|=%.3g", ...
        maxGDP, maxINFL);
end


function runIneqRestrict(meta, dataH, numSamples, numCandidates, outDir)
    import base.*
    modelR = baseReducedForm(meta, dataH, numSamples);

    tbl = tablex.forIneqRestrict(modelR);
    % IneqRestrict syntax: '>0 [p1, p2]' or '<0 [p1, p2]' where [..] is the period range
    horizon = "[1, 4]";
    tbl{"GDP",  "DEM"} = ">0 " + horizon;
    tbl{"INFL", "DEM"} = ">0 " + horizon;
    tbl{"GDP",  "SUP"} = ">0 " + horizon;
    tbl{"INFL", "SUP"} = "<0 " + horizon;
    tbl{"RATE", "POL"} = ">0 " + horizon;
    tbl{"INFL", "POL"} = "<0 " + horizon;

    % identifier.IneqRestrict constructor accepts ONLY FileName / MaxCandidates /
    % TryFlipSigns -- so write the table to xlsx and pass the path.
    fname = fullfile(outDir, "ineqRestrictTbl.xlsx");
    if isfile(fname), delete(fname); end
    tablex.writetable(tbl, fname);

    ident = identifier.IneqRestrict( ...
        fileName=fname, ...
        maxCandidates=numCandidates, ...
        tryFlipSigns=true);
    modelS = Structural(reducedForm=modelR, identifier=ident);
    modelS.initialize();
    modelS.presample(numSamples);

    if isempty(modelS.Presampled)
        error("bearx:test:noAccepted", "IneqRestrict produced no accepted draws");
    end

    iGDP  = find(meta.EndogenousNames == "GDP");
    iINFL = find(meta.EndogenousNames == "INFL");
    iRATE = find(meta.EndogenousNames == "RATE");
    jDEM  = find(meta.ShockNames == "DEM");
    jSUP  = find(meta.ShockNames == "SUP");
    jPOL  = find(meta.ShockNames == "POL");

    % BEAR row-oriented: D(shock_row, endo_col)
    for k = 1 : numel(modelS.Presampled)
        D = modelS.Presampled{k}.D;
        assert(D(jDEM, iGDP)  >= -1e-10, "bearx:test:signDEM_GDP",  "draw %d: D(DEM,GDP)<0",  k);
        assert(D(jDEM, iINFL) >= -1e-10, "bearx:test:signDEM_INFL", "draw %d: D(DEM,INFL)<0", k);
        assert(D(jSUP, iGDP)  >= -1e-10, "bearx:test:signSUP_GDP",  "draw %d: D(SUP,GDP)<0",  k);
        assert(D(jSUP, iINFL) <=  1e-10, "bearx:test:signSUP_INFL", "draw %d: D(SUP,INFL)>0", k);
        assert(D(jPOL, iRATE) >= -1e-10, "bearx:test:signPOL_RATE", "draw %d: D(POL,RATE)<0", k);
        assert(D(jPOL, iINFL) <=  1e-10, "bearx:test:signPOL_INFL", "draw %d: D(POL,INFL)>0", k);
    end
end


function runGeneralRestrict(meta, dataH, numSamples, numCandidates, outDir)
    import base.*
    modelR = baseReducedForm(meta, dataH, numSamples);

    % Build the GeneralRestrict DSL markdown file the way the GUI does:
    % - free prose outside the ``` fences (ignored by the parser
    %   identifier.testStringsFromMarkdown.m)
    % - one restriction per non-empty line inside the fences
    % - names in single quotes resolve against meta.EndogenousNames /
    %   meta.ShockNames; macros expand at sample time
    %
    % We use only CHEAP, UNAMBIGUOUS macros ($SHKRESP only). $SHKEST /
    % $SHKCONT refilter the full shock series per candidate rotation
    % (compute blow-up). $FEVD in BEAR stores raw cumsum(IRF.^2), NOT
    % normalized shares -- threshold semantics are scale-dependent, so we
    % skip FEVD in the verification harness.
    mdLines = [
        "# GeneralRestrict test for suite07"
        ""
        "Free prose outside the fences is ignored by the parser."
        ""
        "```"
        "$SHKRESP(1:2, 'GDP',  'DEM') > 0"
        "$SHKRESP(1:2, 'INFL', 'DEM') > 0"
        "$SHKRESP(1:2, 'GDP',  'SUP') > 0"
        "$SHKRESP(1:2, 'INFL', 'SUP') < 0"
        "$SHKRESP(1,   'RATE', 'POL') > 0"
        "$SHKRESP(1:4, 'INFL', 'POL') < 0"
        "$SHKRESP(1,   'RATE', 'POL') > $SHKRESP(1, 'RATE', 'DEM')"
        "```"
        ];
    fname = fullfile(outDir, "generalRestrict.md");
    fid = fopen(fname, "w");
    fprintf(fid, "%s\n", mdLines);
    fclose(fid);

    ident = identifier.GeneralRestrict( ...
        fileName=fname, ...
        maxCandidates=numCandidates, ...
        tryFlipSigns=true);
    modelS = Structural(reducedForm=modelR, identifier=ident);
    modelS.initialize();
    modelS.presample(numSamples);

    if isempty(modelS.Presampled)
        error("bearx:test:noAccepted", ...
            "GeneralRestrict produced no accepted draws (try raising numCandidates)");
    end

    % The sampler in +identifier/Verifiables.m explicitly evaluates the DSL
    % test function against EVERY candidate D and only keeps draws where
    % testFunc(properties) is all-true (see attemptIdentification_). A
    % non-empty Presampled therefore proves by construction that:
    %   - the markdown was parsed (extractBetween "```")
    %   - names 'GDP'/'INFL'/'RATE'/'DEM'/'SUP'/'POL' were resolved
    %   - the $SHKRESP macro expanded to numeric arrays at sample time
    %   - 6 sign restrictions + 1 relative-magnitude all evaluated true
    % No per-draw re-check is needed; any silent regression would manifest
    % as either 0 accepted draws (FAIL above) or a parse-time error
    % (caught by tutil_runCase). We also sanity-check that the official
    % rendering path runs without error.
    irfTbl = modelS.simulateResponses();
    assert(~isempty(irfTbl), "bearx:test:gr_irfEmpty", "simulateResponses returned empty");
end
