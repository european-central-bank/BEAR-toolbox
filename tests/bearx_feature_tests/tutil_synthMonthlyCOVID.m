function [csvPath, turningPointDate] = tutil_synthMonthlyCOVID(opts)
%TUTIL_SYNTHMONTHLYCOVID  Monthly synthetic VAR(p) with a COVID-style
%   volatility spike. Designed for CCMM* and LargeShock* SV estimators
%   (see BEARX-tutorials-master/test5_CCMM.m for the canonical recipe).
%
%   Layout:
%     - 3 endogenous (RPI, INDPRO, UNRATE-like)
%     - monthly frequency, 32 years (384 obs) from 1990-Jan to 2021-Dec
%     - low-vol regime from start to turningPoint (default 2020-Mar)
%     - high-vol regime after turningPoint: residual cov scaled x100
%     - 3 isolated outliers in [turningPoint, turningPoint+6]
%
%   Returns:
%     csvPath           - absolute path of the generated CSV
%     turningPointDate  - datex.m datetime to feed Turningpoint settings

    arguments
        opts.fileName       (1, 1) string = "synthMonthlyCOVID.csv"
        opts.startYear      (1, 1) double = 1990
        opts.startMonth     (1, 1) double = 1
        opts.numObs         (1, 1) double = 384      % 32 years
        opts.turningOffset  (1, 1) double = 363      % 2020-Mar in default
        opts.highVolFactor  (1, 1) double = 100      % cov(post) = 100 * cov(pre)
    end

    rng(0);
    n = 3;                                  % endogenous
    p = 2;                                  % VAR order (small for speed; CCMM tutorial uses 12)
    T = opts.numObs;
    burn = 50;

    % Stable AR matrices
    A1 = [ 0.6  0.05 -0.10;
          -0.05 0.5   0.05;
           0.10 0.10  0.7];
    A2 = [ 0.1  0.0   0.0;
           0.0  0.05  0.0;
           0.0 -0.05  0.1];
    c  = [0.5; 0.2; 0.3];

    SigmaLow = [ 0.40  0.10 -0.05;
                 0.10  0.30  0.05;
                -0.05  0.05  0.25];

    % High-vol regime: scale the WHOLE covariance, not just diagonal
    SigmaHigh = opts.highVolFactor * SigmaLow;
    Llow  = chol(SigmaLow,  "lower");
    Lhigh = chol(SigmaHigh, "lower");

    % Generate
    totalLen = T + burn + p;
    Y = zeros(n, totalLen);
    regimeBoundaryRaw = opts.turningOffset + burn + p;
    for t = p + 1 : totalLen
        if t < regimeBoundaryRaw
            eps_ = Llow * randn(n, 1);
        else
            eps_ = Lhigh * randn(n, 1);
        end
        Y(:, t) = c + A1 * Y(:, t-1) + A2 * Y(:, t-2) + eps_;
    end
    Y = Y(:, end - T + 1 : end)';      % T x n

    % Inject a handful of isolated COVID-like outliers right at the boundary
    outlierIdx = opts.turningOffset + [0, 1, 3];
    outlierIdx(outlierIdx > T) = [];
    Y(outlierIdx, :) = Y(outlierIdx, :) + ...
        sign(randn(numel(outlierIdx), n)) .* (3 * sqrt(diag(SigmaHigh)))';

    % Build monthly date column in BEAR's SDMX format: "YYYY-MM"
    % (BEAR rejects "YYYY-MM-DD" -- see +datex/Monthly.m datetimeFromSdmx)
    dates = strings(T, 1);
    yr = opts.startYear;
    mo = opts.startMonth;
    for t = 1 : T
        dates(t) = sprintf("%d-%02d", yr, mo);
        mo = mo + 1;
        if mo > 12, mo = 1; yr = yr + 1; end
    end

    % Column MUST be named "Time" (tablex.fromCsv convention)
    tbl = table(dates, Y(:, 1), Y(:, 2), Y(:, 3), ...
        'VariableNames', {'Time', 'RPI', 'INDPRO', 'UNRATE'});

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);

    % Turning point as a datex.m datetime
    yrTP = opts.startYear + floor((opts.startMonth - 1 + opts.turningOffset - 1) / 12);
    moTP = mod(opts.startMonth - 1 + opts.turningOffset - 1, 12) + 1;
    turningPointDate = datex.m(yrTP, moTP);
end
