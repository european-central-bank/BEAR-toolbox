classdef tTasks < tBEARXBase

    properties
        Data
        OutDir
        ModelS
        ModelR
        FcastSpan
        Meta
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthVAR();
        end

        function makeOutDir(tc)
            fld = fullfile(tc.WorkingFolder, 'task_outputs');
            mkdir(fld)
            tc.OutDir = fld;
        end

        function setupModels(tc)

            [meta, dataH] = tc.buildMeta();
            tc.Meta = meta;
            modelR = base.ReducedForm(meta=meta, dataHolder=dataH, ...
                estimator=base.estimator.NormalWishart(meta));
            modelR.initialize();
            modelR.presample(tc.NumSamples);
            tc.ModelR = modelR;

            modelS = base.Structural(reducedForm=modelR, identifier=identifier.Cholesky());
            modelS.initialize();
            modelS.presample(tc.NumSamples);
            tc.ModelS = modelS;

            tc.FcastSpan = datex.span(datex.q(2020, 1), datex.q(2021, 4));

        end


    end

    methods (Test)

        function tReducedFormEstimation(tc)
            assert(numel(tc.ModelR.Presampled) == tc.NumSamples, ...
                "bearx:test:badCount", "Wrong sample count")
        end

        function tStructuralEstimation(tc)
            assert(numel(tc.ModelS.Presampled) == tc.NumSamples, ...
                "bearx:test:badCount", "Wrong sample count")
        end

        function tReducedFormForecast(tc)
            % Use defaults: forecast(fcastSpan) - StochasticResiduals defaults to true.
            fc = tc.ModelR.forecast(tc.FcastSpan);
            assert(~isempty(fc), "bearx:test:emptyForecast", "Empty reduced-form forecast");
        end

        function tStructuralForecast(tc)
            fc = tc.ModelS.forecast(tc.FcastSpan);
            assert(~isempty(fc), "bearx:test:emptyForecast", "Empty structural forecast");
        end

        function tConditionalForecast_conditionsMet(tc)
            [condTbl, planTbl] = tablex.forConditional(tc.ModelS, tc.FcastSpan); %#ok<ASGLU>
            condDate = datex.q(2020, 2);
            condTbl{condDate, "GDP"} = 1.0;

            fc = tc.ModelS.conditionalForecast(tc.FcastSpan, conditions=condTbl, plan=[]);
            assert(~isempty(fc), "bearx:test:emptyCondForecast", "Empty conditional forecast");

            % Verify median forecast meets the imposed condition
            medianFc = tablex.apply(fc, @(x) median(x, 2));
            actual = medianFc{condDate, "GDP"};
            if iscell(actual), actual = actual{1}; end
            assert(abs(actual - 1.0) < 1e-3, "bearx:test:condNotMet", ...
                "Conditioned value not met: expected 1.0, got %.4g", actual);
        end

        function tShockResponses(tc)
            resp = tc.ModelS.simulateResponses();
            assert(~isempty(resp), "bearx:test:emptyIRF", "Empty IRF table");
            sz = size(tc.ModelS.Presampled{1}.D);
            assert(all(sz == [numel(tc.Meta.EndogenousNames), numel(tc.Meta.ShockNames)]), ...
                "bearx:test:badIRFshape", "IRF D shape mismatch");
        end

        function tShockContributions(tc)
            cont = tc.ModelS.calculateContributions();
            assert(~isempty(cont), "bearx:test:emptyContribs", "Empty contributions");
        end

        function tFEVD(tc)
            % Try calculateFEVD first (current API), fall back to legacy fevd.
            try
                fevdTbl = tc.ModelS.calculateFEVD();
            catch err1
                if err1.identifier == "MATLAB:noSuchMethodOrField"
                    try
                        fevdTbl = tc.ModelS.fevd();
                    catch err2
                        error("bearx:test:noFEVD", ...
                            "Neither calculateFEVD nor fevd exists: %s / %s", ...
                            err1.message, err2.message);
                    end
                else
                    rethrow(err1);
                end
            end
            assert(~isempty(fevdTbl), "bearx:test:emptyFEVD", "Empty FEVD");
        end

        function tSaveXLS(tc)
            tc.checkSaveTable("xlsx")
        end

        function tSaveCSV(tc)
            tc.checkSaveTable("csv")
        end

        function tSaveMat(tc)
            tc.checkSaveTable("mat")
        end

    end

    methods (Access = private)

        function [meta, dataH] = buildMeta(tc)
            import base.*
            inputTbl = tablex.fromCsv(tc.Data);
            inputTbl = tablex.extend(inputTbl, -Inf, datex.q(2022, 4));
            inputTbl.Oil = fillmissing(inputTbl.Oil, "nearest");
            meta = base.Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockNames=["DEM", "SUP", "POL"]);
            dataH = DataHolder(meta, inputTbl);
        end

        function checkSaveTable(tc, fmt)
            fc = tc.ModelR.forecast(tc.FcastSpan);
            fname = fullfile(tc.OutDir, "redForecast." + fmt);
            if strcmpi(fmt, "mat")
                save(fname, "fc");
            else
                % tablex.toFile dispatches on extension (xlsx vs csv)
                tablex.toFile(fc, fname);
            end
            assert(isfile(fname), "bearx:test:fileMissing", ...
                "Expected file not written: %s", fname);
            fi = dir(fname);
            assert(fi.bytes > 0, "bearx:test:fileEmpty", "Output file is empty: %s", fname);
        end

    end
    
end
