function csvPath = tutil_synthMean(opts)
%TUTIL_SYNTHMEAN  Synthetic dataset for Mean-Adjusted VAR.
%   3 endogenous around stable means + a deterministic trend component.

    arguments
        opts.fileName (1, 1) string = "synthMean.csv"
        opts.numObs (1, 1) double = 120
        opts.startYear (1, 1) double = 1990
    end

    rng(5);
    T = opts.numObs; burn = 40;
    A = [0.6 0.05 -0.05; 0.05 0.65 0.05; 0.1 0.1 0.6];
    psi = [2.5; 1.5; 0.5];                              % steady-state means
    Y = repmat(psi, 1, T + burn);
    Sigma = 0.5 * eye(3) + 0.1 * ones(3);
    L = chol(Sigma, "lower");
    for t = 2 : T + burn
        Y(:, t) = psi + A * (Y(:, t-1) - psi) + L * randn(3, 1);
    end
    Y = Y(:, end - T + 1 : end)';

    dates = strings(T, 1); qIdx = 1; yr = opts.startYear;
    for t = 1 : T
        dates(t) = sprintf("%d-Q%d", yr, qIdx);
        qIdx = qIdx + 1; if qIdx > 4, qIdx = 1; yr = yr + 1; end
    end

    tbl = table(dates, Y(:, 1), Y(:, 2), Y(:, 3), ...
        'VariableNames', {'Date', 'GDP', 'INFL', 'RATE'});

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
end
