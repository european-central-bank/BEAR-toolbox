function records = suite02_tvSvEstimators(opts)
%SUITE02_TVSVESTIMATORS  Smoke-test Time-varying + Stochastic Volatility BVARs.
%
%   Quarterly-data cases (BetaTV, GeneralTV, CarrieroSV, CogleySargentSV,
%   RandomInertiaSV) use tutil_synthVAR.
%
%   COVID-style monthly cases (CCMMSV/O/OT, LargeShockSV, GenLargeShockSV)
%   use tutil_synthMonthlyCOVID, which generates a 32-year monthly VAR with
%   a residual-cov scale jump + 3 outliers around 2020-Mar. The
%   `Turningpoint` setting is required by all five and is sourced from the
%   generator directly. CCMM constraints are documented in
%   BEARX-tutorials-master/test5_CCMM.m. LargeShock* hyperparameters are
%   reverse-engineered from +largeshockUtils/scaleFactor.m +
%   postlmpdf.m (theta = [Mult0_row, MultAR0_scalar]).

    arguments
        opts.numSamples (1, 1) double = 50
    end

    records = struct([]);

    % ---- quarterly cases ------------------------------------------------
    csvQ = tutil_synthVAR();
    qCases = {
        "BetaTV",          struct("StabilityThreshold", 0.9999);
        "GeneralTV",       struct();
        "CarrieroSV",      struct();
        "CogleySargentSV", struct();
        "RandomInertiaSV", struct();
    };
    for k = 1 : size(qCases, 1)
        nm  = qCases{k, 1};
        cfg = qCases{k, 2};
        rec = tutil_runCase("suite02_tv_sv", nm, ...
            @() runQuarterly(csvQ, nm, cfg, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end

    % ---- monthly COVID-like cases --------------------------------------
    [csvM, tp] = tutil_synthMonthlyCOVID();

    % CCMM family (documented via test5_CCMM.m)
    ccmmCases = {
        "CCMMSV",   struct("Turningpoint", tp);
        "CCMMSVO",  struct("Turningpoint", tp, "OutlierFreq", 4);
        "CCMMSVOT", struct("Turningpoint", tp, "OutlierFreq", 4);
    };
    for k = 1 : size(ccmmCases, 1)
        nm  = ccmmCases{k, 1};
        cfg = ccmmCases{k, 2};
        rec = tutil_runCase("suite02_tv_sv", nm, ...
            @() runMonthly(csvM, nm, cfg, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end

    % LargeShockSV / GenLargeShockSV: hyperparameters reverse-engineered from
    % +largeshockUtils/scaleFactor.m + postlmpdf.m.
    %   theta       = [Mult0 (row, length K), MultAR0 (scalar)]
    %   K           = number of explicit high-shock periods after Turningpoint
    %                 (Mult0 must be a ROW vector, not column)
    %   Mult0(k)    = scaling factor sf for period T0+k-1 (sigma_t = sf * sigma_avg)
    %   ScaleMult,  = generalized Pareto (scale, shape) prior on Mult0
    %   ShapeMult
    %   MultAR0     = initial mean of AR coefficient driving post-K decay
    %   AlphaMultAR,= Beta prior on MultAR
    %   BetaMultAR
    %   PropStdAR   = MH proposal std on the AR
    lsCfg = struct( ...
        "Turningpoint", tp, ...
        "Mult0",        5,    ...   % K=1: a single high-vol Mar-2020 spike
        "ScaleMult",    0.1,  ...
        "ShapeMult",    1,    ...
        "PropStdMult",  0.1,  ...
        "MultAR0",      0.5,  ...
        "AlphaMultAR",  2,    ...
        "BetaMultAR",   2,    ...
        "PropStdAR",    0.05);
    for nm = ["LargeShockSV", "GenLargeShockSV"]
        rec = tutil_runCase("suite02_tv_sv", nm, ...
            @() runMonthly(csvM, nm, lsCfg, opts.numSamples));
        records = [records, rec]; %#ok<AGROW>
    end
end


function runQuarterly(csvPath, estimName, cfg, numSamples)
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
    runEstimator(dataH, meta, estimName, cfg, numSamples);
end


function runMonthly(csvPath, estimName, cfg, numSamples)
    import base.*

    inputTbl = tablex.fromCsv(csvPath);
    % CSV spans 1990-01..2021-12. Leave a 2-month margin at start for
    % order=2 lags (mirrors test5_CCMM.m which starts at month 3 of its
    % data) and stop before the last CSV obs.
    meta = Meta( ...
        endogenousNames=["RPI", "INDPRO", "UNRATE"], ...
        order=2, intercept=true, ...
        estimationSpan=datex.span(datex.m(1990, 3), datex.m(2021, 3)), ...
        identificationHorizon=8);

    dataH = DataHolder(meta, inputTbl);
    runEstimator(dataH, meta, estimName, cfg, numSamples);
end


function runEstimator(dataH, meta, estimName, cfg, numSamples)
    import base.*
    ctor = str2func("base.estimator." + estimName);
    est = ctor(meta);

    % Apply setting overrides
    keys = fieldnames(cfg);
    for j = 1 : numel(keys)
        try
            est.Settings.(keys{j}) = cfg.(keys{j});
        catch
            % silently ignore if the setting is not exposed
        end
    end

    model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
    model.initialize();
    model.presample(numSamples);

    assert(~isempty(model.Presampled), "bearx:test:noPresampled", ...
        "model.Presampled is empty after presample()");
    % Coefficient field name varies across estimator families: plain BVARs
    % use `beta`, CCMM/LargeShock use `B`. Accept either.
    s = model.Presampled{1};
    hasCoeff = isfield(s, "beta") || isfield(s, "B");
    assert(hasCoeff, "bearx:test:emptyBeta", ...
        "Presampled{1} has no recognized coefficient field (beta/B)");
end
