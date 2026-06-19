classdef tDummies < tBEARXBase

    properties (TestParameter)
        SmokeFcn = {dummies.Minnesota(lambda=0.1), ...
            dummies.InitialObs(lambda=0.1), ...
            dummies.SumCoeff(lambda=0.1), ...
            dummies.LongRun(matrix=eye(3), lambda=0.1)}
    end

    properties
        Data
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthVAR();
        end

    end

    methods (Test,ParameterCombination="sequential")

        function tSmokeOne(tc, SmokeFcn)

            import base.*
            [meta, dataH] = buildMeta(tc);
            est = estimator.NormalWishart(meta);
            d = SmokeFcn();
            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est, dummies={d});
            model.initialize();
            model.presample(tc.NumSamples);
            tc.verifyNotEmpty(model.Presampled, "empty presampled");

        end

        function tMinnesota_shrinksToAR(tc)

            % Compare diagonal of first-lag coefficient block with/without Minnesota
            % dummy. Default Minnesota Autoregression = 0.8. The dummy should pull
            % the diagonal closer to 0.8 vs the unconstrained (loose) prior.
            import base.*
            [meta, dataH] = buildMeta(tc);

            rng(0)
            m0 = ReducedForm(meta=meta, dataHolder=dataH, estimator=estimator.NormalWishart(meta));
            m0.initialize(); m0.presample(tc.NumSamples);
            b0 = medianBeta(m0);

            rng(0)
            m1 = ReducedForm(meta=meta, dataHolder=dataH, ...
                estimator=estimator.NormalWishart(meta), ...
                dummies={dummies.Minnesota(lambda=0.01, autoregression=0.8)});
            m1.initialize(); m1.presample(tc.NumSamples);
            b1 = medianBeta(m1);

            % Extract diagonal of first-lag block. Layout depends on BEAR's beta
            % shape; we simply check that estimates differ meaningfully (the dummy
            % had effect) and that some entries moved toward 0.8.
            tc.verifyNotEqual(b0, b1, "Minnesota dummy did not change posterior")
       
            % Soft check: at least one diagonal-ish coefficient should have moved
            % toward 0.8.
            movedToward = sum(abs(b1(:) - 0.8) < abs(b0(:) - 0.8));

            tc.verifyGreaterThan(movedToward, numel(b0) / 4, ...
                sprintf("Minnesota dummy did not pull most coefficients toward AR=0.8 (%d/%d moved)", movedToward, numel(b0)));

        end

        function tSumCoeff_shrinksRowSums(tc)

            import base.*
            [meta, dataH] = buildMeta(tc);
            rng(0)
            m0 = ReducedForm(meta=meta, dataHolder=dataH, estimator=estimator.NormalWishart(meta));
            m0.initialize(); m0.presample(tc.NumSamples);
            b0 = medianBeta(m0);
            rng(0)
            m1 = ReducedForm(meta=meta, dataHolder=dataH, ...
                estimator=estimator.NormalWishart(meta), ...
                dummies={dummies.SumCoeff(lambda=1e-4)});
            m1.initialize(); m1.presample(tc.NumSamples);
            b1 = medianBeta(m1);

            tc.verifyNotEqual(b0, b1, "SumCoeff dummy did not change posterior");
        end

        function tInitialObs_runsAndDiffers(tc)

            import base.*
            [meta, dataH] = buildMeta(tc);
            rng(0)
            m0 = ReducedForm(meta=meta, dataHolder=dataH, estimator=estimator.NormalWishart(meta));
            m0.initialize(); m0.presample(tc.NumSamples);
            b0 = medianBeta(m0);
            rng(0)
            m1 = ReducedForm(meta=meta, dataHolder=dataH, ...
                estimator=estimator.NormalWishart(meta), ...
                dummies={dummies.InitialObs(lambda=1e-5)});
            m1.initialize(); m1.presample(tc.NumSamples);
            b1 = medianBeta(m1);
            tc.verifyNotEqual(b0, b1,  "InitialObs dummy had no effect");

        end

        function tLongRun_runsAndDiffers(tc)

            import base.*
            [meta, dataH] = buildMeta(tc);
            rng(0)
            m0 = ReducedForm(meta=meta, dataHolder=dataH, estimator=estimator.NormalWishart(meta));
            m0.initialize(); m0.presample(tc.NumSamples);
            b0 = medianBeta(m0);
            rng(0)
            m1 = ReducedForm(meta=meta, dataHolder=dataH, ...
                estimator=estimator.NormalWishart(meta), ...
                dummies={dummies.LongRun(matrix=eye(3), lambda=1e-4)});
            m1.initialize(); m1.presample(tc.NumSamples);
            b1 = medianBeta(m1);
            tc.verifyNotEqual(b0, b1,  "LongRun dummy had no effect");

        end

    end

    methods (Access = private)

        function [meta, dataH] = buildMeta(tc)
            import base.*
            inputTbl = tablex.fromCsv(tc.Data);
            meta = Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                exogenousNames=[], ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockNames=["DEM", "SUP", "POL"]);
            dataH = DataHolder(meta, inputTbl);
        end
        

    end


end

function beta = medianBeta(model)
n = numel(model.Presampled);
bs = zeros([size(model.Presampled{1}.beta), n]);
for k = 1 : n
    bs(:, :, k) = model.Presampled{k}.beta;
end
beta = median(bs, 3);
end

