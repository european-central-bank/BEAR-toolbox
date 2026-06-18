function csvPath = tutil_synthVAR(opts)
%TUTIL_SYNTHVAR  Synthetic stable VAR(2) with 3 endogenous + 1 exogenous,
%   120 quarters (1990-Q1 → 2019-Q4). Deterministic (rng(0)).
%   Returns the absolute path of the generated CSV.

    arguments
        opts.fileName (1, 1) string = "synthVAR.csv"
        opts.numObs (1, 1) double = 120
        opts.startYear (1, 1) double = 1990
    end

    rng(0);
    n = 3;                                  % endogenous: GDP, INFL, RATE
    p = 2;                                  % VAR order
    T = opts.numObs;
    burn = 50;

    % Stable AR matrices (eigenvalues < 1)
    A1 = [ 0.5  0.05 -0.10;
          -0.05 0.6   0.05;
           0.10 0.10  0.7];
    A2 = [ 0.1  0.0   0.0;
           0.0  0.05  0.0;
           0.0 -0.05  0.1];
    c  = [0.5; 0.2; 0.3];
    bExo = [0.2; 0.1; 0.4];                 % exogenous "Oil" loading

    % Generate exogenous: stationary AR(1) around mean
    oil = zeros(T + burn + p, 1);
    oil(1) = 50;
    for t = 2 : numel(oil)
        oil(t) = 0.9 * oil(t-1) + 5 + 2 * randn();
    end

    Sigma = [ 1.00  0.20 -0.10;
              0.20  0.80  0.15;
             -0.10  0.15  0.60];
    L = chol(Sigma, "lower");

    Y = zeros(n, T + burn + p);
    for t = p + 1 : T + burn + p
        Y(:, t) = c + A1 * Y(:, t-1) + A2 * Y(:, t-2) + bExo * oil(t) + L * randn(n, 1);
    end
    Y = Y(:, end - T + 1 : end)';                       % T × n
    oilOut = oil(end - T + 1 : end);

    % Build a date column (quarterly)
    dates = strings(T, 1);
    qIdx = 1;
    yr = opts.startYear;
    for t = 1 : T
        dates(t) = sprintf("%d-Q%d", yr, qIdx);
        qIdx = qIdx + 1;
        if qIdx > 4, qIdx = 1; yr = yr + 1; end
    end

    tbl = table(dates, Y(:, 1), Y(:, 2), Y(:, 3), oilOut, ...
        'VariableNames', {'Date', 'GDP', 'INFL', 'RATE', 'Oil'});

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
end
