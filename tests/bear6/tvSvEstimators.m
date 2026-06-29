classdef tvSvEstimators < tBEARXBase

    properties (TestParameter)
        % EstimName = {'BetaTV', 'GeneralTV', 'CarrieroSV', 'CogleySargentSV', 'RandomInertiaSV'}
        % Cfg = {struct("StabilityThreshold", 0.9999), struct(), struct(), struct(), struct() }
        % EstimNameCCMM = {'CCMMSV', 'CCMMSVO', 'CCMMSVOT'}
        % CfgCCMM = { struct(),  struct("OutlierFreq", 4), struct("OutlierFreq", 4)}
        % EstimNameLarge = {'LargeShockSV', 'GenLargeShockSV'}

        EstimName = {'BetaTV', 'GeneralTV', 'CarrieroSV', 'CogleySargentSV', 'RandomInertiaSV', 'CCMMSV', 'CCMMSVO', 'CCMMSVOT', 'LargeShockSV', 'GenLargeShockSV'}
        Frequency = {'Quarterly', 'Quarterly', 'Quarterly', 'Quarterly', 'Quarterly', 'Monthly', 'Monthly', 'Monthly', 'Monthly', 'Monthly'}
        Cfg = {struct("StabilityThreshold", 0.9999), struct(), struct(), struct(), struct(), ...
            struct("Turningpoint", "tp"),  struct("Turningpoint", "tp", "OutlierFreq", 4), struct("Turningpoint", "tp", "OutlierFreq", 4), ...
            struct( ...
            "Turningpoint", "tp", ...
            "Mult0",        5,    ...   % K=1: a single high-vol Mar-2020 spike
            "ScaleMult",    0.1,  ...
            "ShapeMult",    1,    ...
            "PropStdMult",  0.1,  ...
            "MultAR0",      0.5,  ...
            "AlphaMultAR",  2,    ...
            "BetaMultAR",   2,    ...
            "PropStdAR",    0.05), ...
            struct( ...
            "Turningpoint", "tp", ...
            "Mult0",        5,    ...   % K=1: a single high-vol Mar-2020 spike
            "ScaleMult",    0.1,  ...
            "ShapeMult",    1,    ...
            "PropStdMult",  0.1,  ...
            "MultAR0",      0.5,  ...
            "AlphaMultAR",  2,    ...
            "BetaMultAR",   2,    ...
            "PropStdAR",    0.05)}
    end

    properties
        DataQ
        DataM
        TP
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.DataQ = tc.synthVAR();
            [csvPath, turningPointDate] = tc.synthMonthlyCOVID;
            tc.DataM = csvPath;
            tc.TP = turningPointDate;
        end

    end

    methods (Test,ParameterCombination="sequential")

        function tSvEstimators(tc, EstimName, Frequency, Cfg)
            if isfield(Cfg, 'Turningpoint')
                Cfg.Turningpoint = tc.TP;
            end

            switch Frequency
                case "Quarterly"
                    tc.runQuarterly(EstimName, Cfg)
                case "Monthly"
                    tc.runMonthly(EstimName, Cfg)
            end
        end   

    end

    methods (Access = private)

        function runQuarterly(tc, EstimName, Cfg)

            import base.*

            inputTbl = tablex.fromCsv(tc.DataQ);
            meta = Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockNames=["DEM", "SUP", "POL"]);

            dataH = DataHolder(meta, inputTbl);

            tc.runEstimator(dataH, meta, EstimName, Cfg, tc.NumSamples)

        end

        function runMonthly(tc, estimName, Cfg)

            import base.*

            inputTbl = tablex.fromCsv(tc.DataM);
            % CSV spans 1990-01..2021-12. Leave a 2-month margin at start for
            % order=2 lags (mirrors test5_CCMM.m which starts at month 3 of its
            % data) and stop before the last CSV obs.
            meta = Meta( ...
                endogenousNames=["RPI", "INDPRO", "UNRATE"], ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.m(1990, 3), datex.m(2021, 3)), ...
                identificationHorizon=8);

            dataH = DataHolder(meta, inputTbl);

            tc.runEstimator(dataH, meta, estimName, Cfg, tc.NumSamples)

        end

        function runEstimator(tc, dataH, meta, estimName, cfg, numSamples)

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

            tc.verifyNotEmpty(model.Presampled, "model.Presampled is empty after presample()");
            % Coefficient field name varies across estimator families: plain BVARs
            % use `beta`, CCMM/LargeShock use `B`. Accept either.
            s = model.Presampled{1};
            hasCoeff = isfield(s, "beta") || isfield(s, "B");
            tc.verifyTrue(hasCoeff, "Presampled{1} has no recognized coefficient field (beta/B)");

        end
    end

end