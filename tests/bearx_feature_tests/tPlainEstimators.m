classdef tPlainEstimators < tBEARXBase

    properties (TestParameter)
        EstimName = {'NormalWishart', 'Minnesota', 'IndNormalWishart', ...
            'NormalDiffuse', 'Flat', 'Ordinary'}
    end

    properties
        Data
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthVAR();
        end

    end

    methods (Test)

        function tPlain(tc, EstimName)

            NumSamples = tc.NumSamples;

            inputTbl   = tablex.fromCsv(tc.Data);
            estimStart = datex.q(1990, 3);             % skip 2 obs for VAR(2) init
            estimEnd   = datex.q(2019, 4);

            meta = base.Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(estimStart, estimEnd), ...
                identificationHorizon=8, ...
                shockNames=["DEM", "SUP", "POL"]);

            dataH = base.DataHolder(meta, inputTbl);

            ctor = str2func("base.estimator." + EstimName);
            est = ctor(meta);

            model = base.ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            model.initialize();
            info = model.presample(NumSamples); %#ok<NASGU>

            tc.verifyNumElements(model.Presampled, NumSamples, ...
                sprintf("Expected %d presampled draws, got %d", NumSamples, numel(model.Presampled)));

            tc.verifyNotEmpty(model.Presampled{1}.beta, "Presampled{1}.beta is empty")

        end

    end

end