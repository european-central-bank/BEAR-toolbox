classdef tPanelEstimators < tBEARXBase

    properties (TestParameter)
        SepCases = {'NormalWishartPanel', 'MeanOLSPanel', 'ZellnerHongPanel', 'HierarchicalPanel'}
        CrossCases = {'StaticCrossPanel', 'DynamicCrossPanel'}
    end

    properties
        Data
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthPanel();
        end

    end

    methods (Test,ParameterCombination="sequential")

        function tSeparable(tc, SepCases)

            import separable.*

            inputTbl = tablex.fromCsv(tc.Data);
            meta = Meta( ...
                endogenousConcepts=["YER", "HICSA", "STN"], ...
                units=["US", "EA", "UK"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1995, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockConcepts=["DEM", "SUP", "POL"]);
            dataH = DataHolder(meta, inputTbl);

            ctor = str2func("separable.estimator." + SepCases);
            est = ctor(meta);

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            model.presample(tc.NumSamples);

            tc.verifyNotEmpty(model.Presampled,  "empty presampled");

        end

        function tCross(tc, CrossCases)

            import cross.*

            inputTbl = tablex.fromCsv(tc.Data);
            meta = Meta( ...
                endogenousConcepts=["YER", "HICSA", "STN"], ...
                units=["US", "EA", "UK"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1995, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockConcepts=["DEM", "SUP", "POL"]);
            dataH = DataHolder(meta, inputTbl);

            ctor = str2func("cross.estimator." + CrossCases);
            est = ctor(meta);

            model = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            model.presample(tc.NumSamples);

            tc.verifyNotEmpty(model.Presampled, "empty presampled");

        end

    end

end