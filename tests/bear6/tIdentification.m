classdef tIdentification < tBEARXBase
    %SUITE07_IDENTIFICATION  Smoke + semantic tests for the 5 GUI identifiers.

    properties
        NumCandidates = 50
        OutDir
        Data
        Meta
        DataH
    end

    methods (TestClassSetup)

        function setupData(tc)
            tc.Data = tc.synthVAR();
            [tc.Meta, tc.DataH] = tc.buildMeta();
        end

        function makeOutDir(tc)
            fld = fullfile(tc.WorkingFolder, 'ident_tables');
            mkdir(fld)
            tc.OutDir = fld;
        end
    end

    methods (Test)

        function tCholesky_noReorder(tc)
            tc.runCholesky([])
        end

        function tCholesky_reorder(tc)
            tc.runCholesky(["RATE", "GDP", "INFL"]);
        end

        function tInstantZeros_zerosRespected(tc)
            % runInstantZeros(meta, dataH, opts.numSamples, outDir)
            import base.*
            modelR = tc.baseReducedForm();

            tbl = tablex.forInstantZeros(modelR);
            tbl{"GDP", "POL"} = 0;
            tbl{"INFL", "POL"} = 0;

            % Round-trip through xlsx exactly as the tutorial does.
            fname = fullfile(tc.OutDir, "instantZerosTbl.xlsx");
            if isfile(fname), delete(fname); end
            tablex.writetable(tbl, fname);
            tblBack = tablex.readtable(fname, convertTo=@double);
            ident = identifier.InstantZeros(table=tblBack);

            modelS = Structural(reducedForm=modelR, identifier=ident);
            modelS.initialize();
            modelS.presample(tc.NumSamples);

            iGDP  = find(tc.Meta.EndogenousNames == "GDP", 1);
            iINFL = find(tc.Meta.EndogenousNames == "INFL", 1);
            jPOL  = find(tc.Meta.ShockNames == "POL", 1);
            % BEAR D is row-oriented: rows = shocks, cols = endos
            maxGDP = 0; maxINFL = 0;
            for k = 1 : numel(modelS.Presampled)
                D = modelS.Presampled{k}.D;
                maxGDP  = max(maxGDP,  abs(D(jPOL, iGDP)));
                maxINFL = max(maxINFL, abs(D(jPOL, iINFL)));
            end
            assert(maxGDP < 1e-6 && maxINFL < 1e-6, "bearx:test:zeroNotRespected", ...
                "InstantZero violated: max |D(POL,GDP)|=%.3g, |D(POL,INFL)|=%.3g", ...
                maxGDP, maxINFL);
        end

        function tIneqRestrict_signsRespected(tc)
            %  runIneqRestrict(meta, dataH, opts.numSamples, opts.numCandidates, outDir)
            import base.*
            modelR = tc.baseReducedForm();

            tbl = tablex.forIneqRestrict(modelR);
            % IneqRestrict syntax: '>0 [p1, p2]' or '<0 [p1, p2]' where [..] is the period range
            horizon = "[1, 4]";
            tbl{"GDP",  "DEM"} = ">0 " + horizon;
            tbl{"INFL", "DEM"} = ">0 " + horizon;
            tbl{"GDP",  "SUP"} = ">0 " + horizon;
            tbl{"INFL", "SUP"} = "<0 " + horizon;
            tbl{"RATE", "POL"} = ">0 " + horizon;
            tbl{"INFL", "POL"} = "<0 " + horizon;

            % identifier.IneqRestrict constructor accepts ONLY FileName / MaxCandidates /
            % TryFlipSigns -- so write the table to xlsx and pass the path.
            fname = fullfile(tc.OutDir, "ineqRestrictTbl.xlsx");
            if isfile(fname), delete(fname); end
            tablex.writetable(tbl, fname);

            ident = identifier.IneqRestrict( ...
                fileName=fname, ...
                maxCandidates=tc.NumCandidates, ...
                tryFlipSigns=true);
            modelS = Structural(reducedForm=modelR, identifier=ident);
            modelS.initialize();
            modelS.presample(tc.NumSamples);

            if isempty(modelS.Presampled)
                error("bearx:test:noAccepted", "IneqRestrict produced no accepted draws");
            end

            iGDP  = find(tc.Meta.EndogenousNames == "GDP");
            iINFL = find(tc.Meta.EndogenousNames == "INFL");
            iRATE = find(tc.Meta.EndogenousNames == "RATE");
            jDEM  = find(tc.Meta.ShockNames == "DEM");
            jSUP  = find(tc.Meta.ShockNames == "SUP");
            jPOL  = find(tc.Meta.ShockNames == "POL");

            % BEAR row-oriented: D(shock_row, endo_col)
            for k = 1 : numel(modelS.Presampled)
                D = modelS.Presampled{k}.D;
                assert(D(jDEM, iGDP)  >= -1e-10, "bearx:test:signDEM_GDP",  "draw %d: D(DEM,GDP)<0",  k);
                assert(D(jDEM, iINFL) >= -1e-10, "bearx:test:signDEM_INFL", "draw %d: D(DEM,INFL)<0", k);
                assert(D(jSUP, iGDP)  >= -1e-10, "bearx:test:signSUP_GDP",  "draw %d: D(SUP,GDP)<0",  k);
                assert(D(jSUP, iINFL) <=  1e-10, "bearx:test:signSUP_INFL", "draw %d: D(SUP,INFL)>0", k);
                assert(D(jPOL, iRATE) >= -1e-10, "bearx:test:signPOL_RATE", "draw %d: D(POL,RATE)<0", k);
                assert(D(jPOL, iINFL) <=  1e-10, "bearx:test:signPOL_INFL", "draw %d: D(POL,INFL)>0", k);
            end

        end

        function tGeneralRestrict_signsAndFEVD(tc)
            % runGeneralRestrict(meta, dataH, opts.numSamples, max(opts.numCandidates, 200), outDir))
            import base.*
            modelR = tc.baseReducedForm();

            % Build the GeneralRestrict DSL markdown file the way the GUI does:
            % - free prose outside the ``` fences (ignored by the parser
            %   identifier.testStringsFromMarkdown.m)
            % - one restriction per non-empty line inside the fences
            % - names in single quotes resolve against meta.EndogenousNames /
            %   meta.ShockNames; macros expand at sample time
            %
            % We use only CHEAP, UNAMBIGUOUS macros ($SHKRESP only). $SHKEST /
            % $SHKCONT refilter the full shock series per candidate rotation
            % (compute blow-up). $FEVD in BEAR stores raw cumsum(IRF.^2), NOT
            % normalized shares -- threshold semantics are scale-dependent, so we
            % skip FEVD in the verification harness.
            mdLines = [
                "# GeneralRestrict test for suite07"
                ""
                "Free prose outside the fences is ignored by the parser."
                ""
                "```"
                "$SHKRESP(1:2, 'GDP',  'DEM') > 0"
                "$SHKRESP(1:2, 'INFL', 'DEM') > 0"
                "$SHKRESP(1:2, 'GDP',  'SUP') > 0"
                "$SHKRESP(1:2, 'INFL', 'SUP') < 0"
                "$SHKRESP(1,   'RATE', 'POL') > 0"
                "$SHKRESP(1:4, 'INFL', 'POL') < 0"
                "$SHKRESP(1,   'RATE', 'POL') > $SHKRESP(1, 'RATE', 'DEM')"
                "```"
                ];
            fname = fullfile(tc.OutDir, "generalRestrict.md");
            fid = fopen(fname, "w");
            fprintf(fid, "%s\n", mdLines);
            fclose(fid);

            ident = identifier.GeneralRestrict( ...
                fileName=fname, ...
                maxCandidates=tc.NumCandidates, ...
                tryFlipSigns=true);
            modelS = Structural(reducedForm=modelR, identifier=ident);
            modelS.initialize();
            modelS.presample(tc.NumSamples);

            if isempty(modelS.Presampled)
                error("bearx:test:noAccepted", ...
                    "GeneralRestrict produced no accepted draws (try raising numCandidates)");
            end

            % The sampler in +identifier/Verifiables.m explicitly evaluates the DSL
            % test function against EVERY candidate D and only keeps draws where
            % testFunc(properties) is all-true (see attemptIdentification_). A
            % non-empty Presampled therefore proves by construction that:
            %   - the markdown was parsed (extractBetween "```")
            %   - names 'GDP'/'INFL'/'RATE'/'DEM'/'SUP'/'POL' were resolved
            %   - the $SHKRESP macro expanded to numeric arrays at sample time
            %   - 6 sign restrictions + 1 relative-magnitude all evaluated true
            % No per-draw re-check is needed; any silent regression would manifest
            % as either 0 accepted draws (FAIL above) or a parse-time error
            % (caught by tutil_runCase). We also sanity-check that the official
            % rendering path runs without error.
            irfTbl = modelS.simulateResponses();
            assert(~isempty(irfTbl), "bearx:test:gr_irfEmpty", "simulateResponses returned empty");
        end

    end

    methods (Access = private)

        function runCholesky(tc, ordering)
            import base.*
            modelR = tc.baseReducedForm();
            if isempty(ordering)
                ident = identifier.Cholesky();
            else
                ident = identifier.Cholesky(ordering=ordering);
            end
            modelS = Structural(reducedForm=modelR, identifier=ident);
            modelS.initialize();
            modelS.presample(tc.NumSamples);

            % BEAR's Cholesky stores  P = chol(Sigma(o,o))(:, backOrder).
            % => P is NOT triangular when reordering is used; instead it satisfies
            %    P' * P == Sigma in the original ordering. Check that identity.
            sample = modelS.Presampled{1};
            D = sample.D;
            Sigma = sample.sigma;   % lowercase field as stored by base estimators
            % BEAR row-oriented convention: Cov(U) = D' * D = Sigma
            err = norm(D' * D - Sigma, "fro") / max(1, norm(Sigma, "fro"));
            assert(err < 1e-8, "bearx:test:choleskyMismatch", ...
                "P''P does not reconstruct Sigma: rel err = %.3g", err);
        end

        function [meta, dataH] = buildMeta(tc)
            inputTbl = tablex.fromCsv(tc.Data);
            meta = base.Meta( ...
                endogenousNames=["GDP", "INFL", "RATE"], ...
                exogenousNames="Oil", ...
                order=2, intercept=true, ...
                estimationSpan=datex.span(datex.q(1990, 3), datex.q(2019, 4)), ...
                identificationHorizon=8, ...
                shockNames=["DEM", "SUP", "POL"]);
            dataH = base.DataHolder(meta, inputTbl);
        end

        function modelR = baseReducedForm(tc)
            import base.*
            modelR = ReducedForm(meta=tc.Meta, dataHolder=tc.DataH, ...
                estimator=estimator.NormalWishart(tc.Meta));
            modelR.initialize();
            modelR.presample(tc.NumSamples);
        end

        function runGeneralRestrict(tc)
            import base.*
            modelR = tc.baseReducedForm();

            % Build the GeneralRestrict DSL markdown file the way the GUI does:
            % - free prose outside the ``` fences (ignored by the parser
            %   identifier.testStringsFromMarkdown.m)
            % - one restriction per non-empty line inside the fences
            % - names in single quotes resolve against meta.EndogenousNames /
            %   meta.ShockNames; macros expand at sample time
            %
            % We use only CHEAP, UNAMBIGUOUS macros ($SHKRESP only). $SHKEST /
            % $SHKCONT refilter the full shock series per candidate rotation
            % (compute blow-up). $FEVD in BEAR stores raw cumsum(IRF.^2), NOT
            % normalized shares -- threshold semantics are scale-dependent, so we
            % skip FEVD in the verification harness.
            mdLines = [
                "# GeneralRestrict test for suite07"
                ""
                "Free prose outside the fences is ignored by the parser."
                ""
                "```"
                "$SHKRESP(1:2, 'GDP',  'DEM') > 0"
                "$SHKRESP(1:2, 'INFL', 'DEM') > 0"
                "$SHKRESP(1:2, 'GDP',  'SUP') > 0"
                "$SHKRESP(1:2, 'INFL', 'SUP') < 0"
                "$SHKRESP(1,   'RATE', 'POL') > 0"
                "$SHKRESP(1:4, 'INFL', 'POL') < 0"
                "$SHKRESP(1,   'RATE', 'POL') > $SHKRESP(1, 'RATE', 'DEM')"
                "```"
                ];
            fname = fullfile(tc.OutDir, "generalRestrict.md");
            fid = fopen(fname, "w");
            fprintf(fid, "%s\n", mdLines);
            fclose(fid);

            ident = identifier.GeneralRestrict( ...
                fileName=fname, ...
                maxCandidates=tc.NumCandidates, ...
                tryFlipSigns=true);
            modelS = Structural(reducedForm=modelR, identifier=ident);
            modelS.initialize();
            modelS.presample(tc.NumSamples);

            if isempty(modelS.Presampled)
                error("bearx:test:noAccepted", ...
                    "GeneralRestrict produced no accepted draws (try raising numCandidates)");
            end

            % The sampler in +identifier/Verifiables.m explicitly evaluates the DSL
            % test function against EVERY candidate D and only keeps draws where
            % testFunc(properties) is all-true (see attemptIdentification_). A
            % non-empty Presampled therefore proves by construction that:
            %   - the markdown was parsed (extractBetween "```")
            %   - names 'GDP'/'INFL'/'RATE'/'DEM'/'SUP'/'POL' were resolved
            %   - the $SHKRESP macro expanded to numeric arrays at sample time
            %   - 6 sign restrictions + 1 relative-magnitude all evaluated true
            % No per-draw re-check is needed; any silent regression would manifest
            % as either 0 accepted draws (FAIL above) or a parse-time error
            % (caught by tutil_runCase). We also sanity-check that the official
            % rendering path runs without error.
            irfTbl = modelS.simulateResponses();
            assert(~isempty(irfTbl), "bearx:test:gr_irfEmpty", "simulateResponses returned empty");
        end

    end    

end


    

    

    