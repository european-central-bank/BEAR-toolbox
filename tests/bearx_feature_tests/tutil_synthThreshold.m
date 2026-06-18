function csvPath = tutil_synthThreshold(opts)
%TUTIL_SYNTHTHRESHOLD  Synthetic VAR with a threshold indicator series.
%   3 endogenous (GDP, INFL, RATE) + 1 exogenous (Oil) + 1 threshold (TI).
%   Deterministic (rng(0)).

    arguments
        opts.fileName (1, 1) string = "synthThreshold.csv"
        opts.numObs (1, 1) double = 120
        opts.startYear (1, 1) double = 1990
    end

    rng(2);
    csvBase = tutil_synthVAR(fileName="synthVAR_for_threshold.csv", numObs=opts.numObs, startYear=opts.startYear);
    tbl = readtable(csvBase, "TextType", "string");

    T = height(tbl);
    % Threshold indicator: smoothed mean-zero series that crosses 0 multiple times
    ti = zeros(T, 1);
    ti(1) = 0;
    for t = 2 : T
        ti(t) = 0.7 * ti(t-1) + 0.3 * sin(2 * pi * t / 30) + 0.2 * randn();
    end
    tbl.TI = ti;

    csvPath = fullfile(tutil_dataDir(), opts.fileName);
    writetable(tbl, csvPath);
    delete(csvBase);
end
