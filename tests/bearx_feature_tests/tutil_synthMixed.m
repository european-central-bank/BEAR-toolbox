function csvPath = tutil_synthMixed(opts)
%TUTIL_SYNTHMIXED  Synthetic mixed-frequency dataset.
%   High-frequency monthly: IP, CPI. Low-frequency quarterly: GDP (NaN except
%   on the third month of each quarter). 240 months ≈ 20 years.
%   Deterministic (rng(0)).

    arguments
        opts.fileName (1, 1) string = "synthMixed.csv"
        opts.numMonths (1, 1) double = 240
        opts.startYear (1, 1) double = 2000
    end

    rng(3);
    T = opts.numMonths;
    burn = 30;

    A = [0.7 0.05 0.0;
         0.05 0.8 0.0;
         0.1  0.1 0.6];
    Sigma = 0.4 * eye(3) + 0.1 * ones(3);
    L = chol(Sigma, "lower");

    Y = zeros(3, T + burn);
    for t = 2 : T + burn
        Y(:, t) = A * Y(:, t-1) + L * randn(3, 1);
    end
    Y = Y(:, end - T + 1 : end)';     % T × 3, columns: IP, CPI, GDPlatent

    % GDP observed quarterly (months ending each quarter)
    months = (1 : T)';
    isQuarterEnd = mod(months, 3) == 0;
    gdp = nan(T, 1);
    gdp(isQuarterEnd) = Y(isQuarterEnd, 3);

    dates = strings(T, 1);
    yr = opts.startYear; mo = 1;
    for t = 1 : T
        dates(t) = sprintf("%d-%02d", yr, mo);
        mo = mo + 1;
        if mo > 12, mo = 1; yr = yr + 1; end
    end

    tbl = table(dates, Y(:, 1), Y(:, 2), gdp, ...
        'VariableNames', {'Date', 'IP', 'CPI', 'GDP'});

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
end
