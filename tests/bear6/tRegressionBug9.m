classdef tRegressionBug9 < matlab.unittest.TestCase


    properties
        CsvPath

    end

    methods (TestClassSetup)
        function loadCSV(tc)
            rootDir = fullfile(currentProject().RootFolder, "BEARX-GUI-Examples"); 
            tc.CsvPath = fullfile(rootDir, "regression_data.csv");
        end
    end

    methods (Test)

        function tS1_nonPanel(tc)
            % S1 — non-panel base BVAR + conditions-only forecast.
            import base.*

            inputTbl = tablex.fromCsv(tc.CsvPath);
            endo  = ["US_YER", "US_HICSA", "US_STN"];
            estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
            meta  = Meta(endogenousNames=endo, order=2, estimationSpan=estSpan);
            dataH = DataHolder(meta, inputTbl);
            est   = base.estimator.NormalWishart(meta);
            red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            red.initialize();
            red.presample(50);
            ident = identifier.Cholesky();
            str   = Structural(reducedForm=red, identifier=ident);
            str.initialize();
            str.presample(50);

            fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
            [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
            % Conditions on one variable, empty plan -> exercises the no-plan branch.
            condTbl{datex.q(2015,2), "US_YER"} = 124.5;
            fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
                exogenousFrom="conditions", includeInitial=false);
            tc.verifyNotEmpty(fc, "S1 produced empty forecast");
        end

        function tS2_panelOneUnit(tc)
            % S2 — 2-country separable panel, shocks restricted to ONE unit per period.
            import separable.*

            inputTbl = tablex.fromCsv(tc.CsvPath);
            endoConcepts  = ["YER", "HICSA", "STN"];
            shockConcepts = ["DEM", "SUP", "POL"];
            units = ["US", "EA"];
            estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
            meta  = Meta(endogenousConcepts=endoConcepts, shockConcepts=shockConcepts, ...
                units=units, order=2, estimationSpan=estSpan);
            dataH = DataHolder(meta, inputTbl);
            est   = separable.estimator.NormalWishartPanel(meta);
            red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            red.initialize();
            red.presample(50);
            ident = identifier.Cholesky();
            str   = Structural(reducedForm=red, identifier=ident);
            str.initialize();
            str.presample(50);

            fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
            [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
            % Shocks only in US for Q2, only in EA for Q3 — never simultaneous.
            condTbl{datex.q(2015,2), "US_STN"} = 5.0;
            planTbl{datex.q(2015,2), "US_STN"} = "DEM";
            condTbl{datex.q(2015,3), "EA_STN"} = 5.5;
            planTbl{datex.q(2015,3), "EA_STN"} = "DEM";
            fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
                exogenousFrom="conditions", includeInitial=false);
            tc.verifyNotEmpty(fc, "S2 produced empty forecast");
        end

        function tS3_panelMultiUnit(tc)
            % S3 — 3-country separable panel, shocks in MULTIPLE units at the SAME period.
            % This is the case Bug 9 fixes. Without the patch: crash in shocksim6:45.
            import separable.*

            inputTbl = tablex.fromCsv(tc.CsvPath);
            endoConcepts  = ["YER", "HICSA", "STN"];
            shockConcepts = ["DEM", "SUP", "POL"];
            units = ["US", "EA", "UK"];
            estSpan = datex.span(datex.q(2000,3), datex.q(2014,4));
            meta  = Meta(endogenousConcepts=endoConcepts, shockConcepts=shockConcepts, ...
                units=units, order=2, estimationSpan=estSpan);
            dataH = DataHolder(meta, inputTbl);
            est   = separable.estimator.NormalWishartPanel(meta);
            red   = ReducedForm(meta=meta, dataHolder=dataH, estimator=est);
            red.initialize();
            red.presample(50);
            ident = identifier.Cholesky();
            str   = Structural(reducedForm=red, identifier=ident);
            str.initialize();
            str.presample(50);

            fcastSpan = datex.span(datex.q(2015,1), datex.q(2015,4));
            [condTbl, planTbl] = tablex.forConditional(str, fcastSpan);
            % Mirror SeparablePanel/master.m: same period, all 3 units.
            condTbl{datex.q(2015,3), "US_STN"} = 5.0;
            condTbl{datex.q(2015,3), "EA_STN"} = 5.5;
            condTbl{datex.q(2015,3), "UK_STN"} = 6.0;
            planTbl{datex.q(2015,3), "US_STN"} = "DEM POL";
            planTbl{datex.q(2015,3), "EA_STN"} = "DEM POL";
            planTbl{datex.q(2015,3), "UK_STN"} = "SUP POL";
            fc = str.conditionalForecast(fcastSpan, conditions=condTbl, plan=planTbl, ...
                exogenousFrom="conditions", includeInitial=false);
            tc.verifyNotEmpty(fc, "S3 produced empty forecast");
        end
    end

end