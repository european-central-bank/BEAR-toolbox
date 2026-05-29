function csvPath = tutil_synthFAVAR(opts)
%TUTIL_SYNTHFAVAR  Synthetic FAVAR dataset.
%   3 endogenous (GDP, INFL, RATE) + 8 "reducible" series driven by 2 latent
%   factors + 1 exogenous (Oil). 120 quarters. Deterministic (rng(0)).

    arguments
        opts.fileName (1, 1) string = "synthFAVAR.csv"
        opts.numObs (1, 1) double = 120
        opts.startYear (1, 1) double = 1990
    end

    rng(4);
    T = opts.numObs; burn = 40;

    % Factors AR(1)
    F = zeros(2, T + burn);
    for t = 2 : T + burn
        F(:, t) = 0.85 * F(:, t-1) + 0.5 * randn(2, 1);
    end

    % 3 endogenous as VAR + small factor loading
    A = [0.6 0.05 -0.05; 0.05 0.7 0.05; 0.1 0.1 0.65];
    Lambda = [0.3 0.1; 0.2 0.3; -0.1 0.2];
    Y = zeros(3, T + burn);
    for t = 2 : T + burn
        Y(:, t) = A * Y(:, t-1) + Lambda * F(:, t) + 0.4 * randn(3, 1);
    end

    % 8 reducible series: linear in factors + idiosyncratic noise
    G = randn(8, 2);
    R = G * F + 0.3 * randn(8, T + burn);

    % Exogenous oil
    oil = zeros(T + burn, 1); oil(1) = 50;
    for t = 2 : T + burn
        oil(t) = 0.9 * oil(t-1) + 5 + 2 * randn();
    end

    Y = Y(:, end - T + 1 : end)';                       % T × 3
    R = R(:, end - T + 1 : end)';                       % T × 8
    oilOut = oil(end - T + 1 : end);

    dates = strings(T, 1);
    qIdx = 1; yr = opts.startYear;
    for t = 1 : T
        dates(t) = sprintf("%d-Q%d", yr, qIdx);
        qIdx = qIdx + 1;
        if qIdx > 4, qIdx = 1; yr = yr + 1; end
    end

    redNames = "R" + string(1:8);
    tbl = array2table([Y, R, oilOut], 'VariableNames', cellstr(["GDP", "INFL", "RATE", redNames, "Oil"]));
    tbl = addvars(tbl, dates, 'Before', 1, 'NewVariableNames', 'Date');

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
end
