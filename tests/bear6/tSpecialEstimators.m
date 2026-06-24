classdef tSpecialEstimators < tBEARXBase

    properties
        Data
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthFAVAR();
        end

    end

    methods (Test)

        function  runThreshold(tc)
            import threshold.*

            csvPath = tc.synthThreshold();
            inputTbl = tablex.fromCsv(csvPath);
            % Threshold indicator MUST be one of the endogenous variables
            meta = Meta( ...
                endogenousNames=["GDP", "INFL", "RATE", "TI"], ...
                thresholdName="TI", ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8);
            dataH = DataHolder(meta, inputTbl);
            est = threshold.estimator.Threshold(meta);
            % Threshold needs prior dummies (Minnesota by convention)
            minnD = dummies.Minnesota();

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est, dummies={minnD});
            model.initialize();
            model.presample(tc.NumSamples);
            tc.verifyNotEmpty(model.Presampled, "empty presampled");
        end

        function runMixed(tc)
            import mixed.*

            csvPath = tc.synthMixed();
            inputTbl = tablex.fromCsv(csvPath);
            % MixedFrequency Kalman needs enough lags; tutorials use order=6
            meta = Meta( ...
                highFrequencyNames=["IP", "CPI"], ...
                lowFrequencyNames="GDP", ...
                order=6, intercept=true, ...
                estimationSpan=datex.span(datex.m(2001, 1), datex.m(2019, 12)), ...
                identificationHorizon=8);
            dataH = DataHolder(meta, inputTbl);
            est = mixed.estimator.MixedFrequency(meta);

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            model.presample(tc.NumSamples);
            tc.verifyNotEmpty(model.Presampled, "empty presampled");
        end

        function runMean(tc)
            % Mean-adjusted BVAR (not exposed by the GUI -- TBD-G3 -- but the
            % toolbox API is fully usable from a script). Adapted from
            % BEARX-tutorials-master/test7_meanAdjusted.m for our synthetic VAR.
            import mean.*

            csvPath = tc.synthVAR();
            inputTbl = tablex.fromCsv(csvPath);

            estimStart = datex.q(1990, 3);
            estimEnd   = datex.q(2019, 4);
            estimSpan  = datex.span(estimStart, estimEnd);
            % Two-regime split on the third endo (RATE), single regime on the others
            turningPoint = datex.q(2008, 1);

            meta = Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                order=2, ...
                estimationSpan=estimSpan, ...
                trendType=["constant", "constant", "constant"], ...
                numRegimes=[1, 1, 2], ...
                regimeSpans={ ...
                {datex.span(estimStart, turningPoint)}, ...
                {datex.span(datex.shift(turningPoint, 1), estimEnd)} ...
                }, ...
                bounds={{[]}, {[]}, {[0 5], [0 5]}}, ...
                identificationHorizon=8);

            dataH = DataHolder(meta, inputTbl);
            est = estimator.MeanAdjusted(meta, ScaleUp=100);

            modelR = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            modelR.initialize();
            modelR.presample(tc.NumSamples);
            assert(~isempty(modelR.Presampled), "bearx:test:noPresampled", ...
                "MeanAdjusted: empty Presampled");

            % Smoke a forecast through the official path
            fcastStart = datex.shift(meta.EstimationEnd, 1);
            fcastEnd   = datex.shift(meta.EstimationEnd, 4);
            fcastTbl   = modelR.forecast(datex.span(fcastStart, fcastEnd));
            tc.verifyNotEmpty(fcastTbl, "MeanAdjusted: forecast returned empty");
        end


    end

end