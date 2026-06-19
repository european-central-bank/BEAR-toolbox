classdef tFavarEstimators < tBEARXBase

    properties (TestParameter)
        OneStep = {'FlatFAVAROnestep', 'IndNormalWishartFAVAROnestep', ...
               'MinnesotaFAVAROnestep', 'NormalDiffuseFAVAROnestep', ...
               'NormalWishartFAVAROnestep'}
        TwoStep = {'BetaTVFAVAR', 'CarrieroSVFAVAR', 'CogleySargentSVFAVAR', ...
               'FlatFAVARTwostep', 'GeneralTVFAVAR', ...
               'IndNormalWishartFAVARTwostep', 'MinnesotaFAVARTwostep', ...
               'NormalDiffuseFAVARTwostep', 'NormalWishartFAVARTwostep', ...
               'RandomInertiaSVFAVAR'}
    end

    properties
        Data
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthFAVAR();
        end

    end

    methods (Test,ParameterCombination="sequential")

        function tOneStep(tc, OneStep)

            import factorOnestep.*

            inputTbl = tablex.fromCsv(tc.Data);
            % Onestep specifics (per test2b_factorOnestep tutorial):
            %   - intercept is NOT allowed (data are standardized internally)
            %   - single block named "main" auto-created from reducibleNames
            %   - one (or few) endo with many reducibles works best
            meta = Meta( ...
                endogenousNames="GDP", ...
                reducibleNames="R" + string(1:8), ...
                numFactors=2, ...
                order=2, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8);
            dataH = DataHolder(meta, inputTbl);

            % Onestep estimator constructors take NO meta argument
            ctor = str2func("factorOnestep.estimator." + OneStep);
            est = ctor();

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            model.presample(tc.NumSamples);

            tc.verifyNotEmpty(model.Presampled, "empty presampled");

        end

        function tTwoStep(tc, TwoStep)

            import factorTwostep.*

            inputTbl = tablex.fromCsv(tc.Data);
            % Mirror test2a_factorTwostep tutorial pattern. SV/IndNW/Minnesota variants
            % require at least 2 endogenous (their samplers index endogenous(2)).
            needsMultiEndo = ["CarrieroSVFAVAR", "CogleySargentSVFAVAR", ...
                "IndNormalWishartFAVARTwostep", "MinnesotaFAVARTwostep", ...
                "NormalDiffuseFAVARTwostep", "NormalWishartFAVARTwostep"];
            if any(TwoStep == needsMultiEndo)
                endoNames = ["GDP", "INFL"];
            else
                endoNames = "GDP";
            end
            nRed = 8;
            blocks = repmat("main", 1, nRed);
            meta = Meta( ...
                endogenousNames=endoNames, ...
                reducibleNames="R" + string(1:nRed), ...
                reducibleBlocks=blocks, ...
                blockType="blocks", ...
                numFactors=struct("main", 2), ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8);
            dataH = DataHolder(meta, inputTbl);

            % Twostep estimator constructors take NO meta argument
            ctor = str2func("factorTwostep.estimator." + TwoStep);
            est = ctor();

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            model.presample(tc.NumSamples);

            tc.verifyNotEmpty(model.Presampled, "empty presampled");

        end

    end

end