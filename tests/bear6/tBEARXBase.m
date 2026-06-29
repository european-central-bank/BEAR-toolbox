classdef tBEARXBase < matlab.unittest.TestCase

    properties
        NumSamples (1,1) double = 50
    end

    properties
        WorkingFolder (1,1) string
        OldDir        (1,1) string
    end

    methods (TestClassSetup)
        function setupFolder(tc)
            % Store current directory
            tc.OldDir = pwd();

            % Setup working folder
            fixture = matlab.unittest.fixtures.TemporaryFolderFixture();
            tc.applyFixture(fixture)
            tc.WorkingFolder = fixture.Folder;
            mkdir(fullfile(tc.WorkingFolder, "data"))
            
            % Move to test folder
            cd(tc.WorkingFolder)
        end
    end

    methods (TestClassTeardown)

        function restoreDir(tc)
            % Restore directory
            cd(tc.OldDir)
        end
        
    end

    methods (Access = protected)

        function csvPath = synthVAR(tc, opts)
            %TUTIL_SYNTHVAR  Synthetic stable VAR(2) with 3 endogenous + 1 exogenous,
            %   120 quarters (1990-Q1 → 2019-Q4). Deterministic (rng(0)).
            %   Returns the absolute path of the generated CSV.

            arguments
                tc
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
                'VariableNames', {'Time', 'GDP', 'INFL', 'RATE', 'Oil'});

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
         
            writetable(tbl, csvPath);
        end       

        function [csvPath, turningPointDate] = synthMonthlyCOVID(tc, opts)
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
                tc
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

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);

            % Turning point as a datex.m datetime
            yrTP = opts.startYear + floor((opts.startMonth - 1 + opts.turningOffset - 1) / 12);
            moTP = mod(opts.startMonth - 1 + opts.turningOffset - 1, 12) + 1;
            turningPointDate = datex.m(yrTP, moTP);
        end

        function csvPath = synthPanel(tc, opts)
            %TUTIL_SYNTHPANEL  Synthetic panel: 3 units × 3 concepts (YER, HICSA, STN) +
            %   1 exogenous (Oil), 100 quarters. Columns: US_YER, US_HICSA, US_STN,
            %   EA_YER, ..., UK_STN, Oil. Deterministic.

            arguments
                tc
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
            tbl = addvars(tbl, dates, 'Before', 1, 'NewVariableNames', 'Time');

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);
        end

        function csvPath = synthFAVAR(tc,opts)
            %TUTIL_SYNTHFAVAR  Synthetic FAVAR dataset.
            %   3 endogenous (GDP, INFL, RATE) + 8 "reducible" series driven by 2 latent
            %   factors + 1 exogenous (Oil). 120 quarters. Deterministic (rng(0)).

            arguments
                tc
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
            tbl = addvars(tbl, dates, 'Before', 1, 'NewVariableNames', 'Time');

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);
        end

        function csvPath = synthThreshold(tc,opts)
            %TUTIL_SYNTHTHRESHOLD  Synthetic VAR with a threshold indicator series.
            %   3 endogenous (GDP, INFL, RATE) + 1 exogenous (Oil) + 1 threshold (TI).
            %   Deterministic (rng(0)).

            arguments
                tc
                opts.fileName (1, 1) string = "synthThreshold.csv"
                opts.numObs (1, 1) double = 120
                opts.startYear (1, 1) double = 1990
            end

            rng(2);
            csvBase = tc.synthVAR(fileName="synthVAR_for_threshold.csv", numObs=opts.numObs, startYear=opts.startYear);
            cobj = onCleanup(@() delete(csvBase));
            tbl = readtable(csvBase, "TextType", "string");

            T = height(tbl);
            % Threshold indicator: smoothed mean-zero series that crosses 0 multiple times
            ti = zeros(T, 1);
            ti(1) = 0;
            for t = 2 : T
                ti(t) = 0.7 * ti(t-1) + 0.3 * sin(2 * pi * t / 30) + 0.2 * randn();
            end
            tbl.TI = ti;

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);
        end

        function csvPath = synthMixed(tc, opts)
            %TUTIL_SYNTHMIXED  Synthetic mixed-frequency dataset.
            %   High-frequency monthly: IP, CPI. Low-frequency quarterly: GDP (NaN except
            %   on the third month of each quarter). 240 months ≈ 20 years.
            %   Deterministic (rng(0)).

            arguments
                tc
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
                'VariableNames', {'Time', 'IP', 'CPI', 'GDP'});

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);
        end

        function csvPath = synthMean(tc, opts)
            %TUTIL_SYNTHMEAN  Synthetic dataset for Mean-Adjusted VAR.
            %   3 endogenous around stable means + a deterministic trend component.

            arguments
                tc
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

            fld = fullfile(tc.WorkingFolder, "data");
            csvPath = fullfile(fld, opts.fileName);
            writetable(tbl, csvPath);
        end

    end


end