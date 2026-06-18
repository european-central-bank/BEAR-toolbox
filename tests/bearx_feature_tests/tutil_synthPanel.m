function csvPath = tutil_synthPanel(opts)
%TUTIL_SYNTHPANEL  Synthetic panel: 3 units × 3 concepts (YER, HICSA, STN) +
%   1 exogenous (Oil), 100 quarters. Columns: US_YER, US_HICSA, US_STN,
%   EA_YER, ..., UK_STN, Oil. Deterministic.

    arguments
        opts.fileName (1, 1) string = "synthPanel.csv"
        opts.numObs (1, 1) double = 100
        opts.startYear (1, 1) double = 1995
        opts.units (1, :) string = ["US", "EA", "UK"]
    end

    rng(1);
    concepts = ["YER", "HICSA", "STN"];
    units = opts.units;
    nU = numel(units);
    nC = numel(concepts);

    % Block-diagonal AR(1) with mild cross-unit linkage
    A = 0.7 * eye(nU * nC) + 0.05 * rand(nU * nC);
    e = abs(eig(A));
    if max(e) >= 0.98
        A = A * (0.95 / max(e));
    end

    T = opts.numObs;
    burn = 40;
    bOil = 0.1 * ones(nU * nC, 1);

    oil = zeros(T + burn, 1); oil(1) = 50;
    for t = 2 : T + burn
        oil(t) = 0.9 * oil(t-1) + 5 + 2 * randn();
    end

    Sigma = 0.5 * eye(nU * nC) + 0.1 * ones(nU * nC);
    L = chol(Sigma, "lower");

    Y = zeros(nU * nC, T + burn);
    for t = 2 : T + burn
        Y(:, t) = A * Y(:, t-1) + bOil * oil(t) + L * randn(nU * nC, 1);
    end
    Y = Y(:, end - T + 1 : end)';
    oilOut = oil(end - T + 1 : end);

    dates = strings(T, 1);
    qIdx = 1; yr = opts.startYear;
    for t = 1 : T
        dates(t) = sprintf("%d-Q%d", yr, qIdx);
        qIdx = qIdx + 1;
        if qIdx > 4, qIdx = 1; yr = yr + 1; end
    end

    varNames = strings(1, nU * nC);
    k = 1;
    for u = 1 : nU
        for c = 1 : nC
            varNames(k) = units(u) + "_" + concepts(c);
            k = k + 1;
        end
    end

    tbl = array2table([Y, oilOut], 'VariableNames', cellstr([varNames, "Oil"]));
    tbl = addvars(tbl, dates, 'Before', 1, 'NewVariableNames', 'Date');

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
end
