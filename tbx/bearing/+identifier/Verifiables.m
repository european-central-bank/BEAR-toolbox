
classdef Verifiables ...
    < identifier.Base

    properties (Constant)
        DEFAULT_MAX_CANDIDATES = 100
        DEFAULT_TRY_FLIP_SIGNS = true
    end


    properties (SetAccess = protected)
        VerifiableTests
        InstantZeros = identifier.InstantZeros()
        IneqRestrictTable (:, :) table
        %
        MaxCandidates (1, 1) double {mustBePositive} = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
        TryFlipSigns (1, 1) logical = identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
        TestStrings (:, 1) string = string.empty(0, 1)
    end


    methods

        function this = Verifiables(testStrings, inputs, options)
            arguments
                testStrings (:, 1) string = string.empty(0, 1)
                %
                inputs.IneqRestrictTable = []
                inputs.InstantZeros = []
                inputs.InstantZerosTable = []
                %
                options.MaxCandidates (1, 1) double = identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.TryFlipSigns (1, 1) logical = identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
                options.FileName (1, 1) string = ""
                % options.ShortCircuit (1, 1) logical = identifier.VerifiableTests.DEFAULT_SHORT_CIRCUIT
            end
            %
            if options.FileName ~= ""
                this.TestStrings = identifier.testStringsFromMarkdown(options.FileName);
            else
                this.TestStrings = testStrings;
            end
            this.MaxCandidates = options.MaxCandidates;
            this.TryFlipSigns = options.TryFlipSigns;
            this.IneqRestrictTable = inputs.IneqRestrictTable;
            this.addInstantZeros(inputs);
            %
        end%


        function whenPairedWithModel(this, modelS)
            if ~isempty(this.InstantZeros)
                this.InstantZeros.whenPairedWithModel(modelS);
            end
            this.populateSeparableNames(modelS.Meta);
            this.addSignRestrictions(modelS);
            this.VerifiableTests = identifier.VerifiableTests(this.TestStrings);
        end%


        function initializeSampler(this, modelS)
            %[
            reducedFormSampler = modelS.ReducedForm.Estimator.Sampler;
            identificationDrawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            historyDrawer = modelS.ReducedForm.Estimator.HistoryDrawer;
            modelR = modelS.ReducedForm;
            %
            % Extract meta information
            meta = modelS.Meta;
            numSeparableResiduals = meta.NumSeparableResidualNames;
            numSeparableUnits = meta.NumSeparableUnits;
            order = meta.Order;
            hasIntercept = meta.HasIntercept;
            EXTRACT_DIM = 3;
            %
            % Get data
            longYX = modelS.getLongYX();
            [longY, longX] = longYX{:};

            numLongPeriods = size(longY, 1);
            numShortPeriods = numLongPeriods - order;
            %
            [testFunc, occurrence] = this.VerifiableTests.buildTestEnvironment(modelS.Meta);
            has = struct();
            for n = ["SHKRESP", "FEVD", "SHKEST", "SHKCONT"]
                has.(n) = isfield(occurrence, n);
            end
            %
            % Initialize the InstantZeros object without a warning
            this.InstantZeros.deinitialize();
            this.InstantZeros.initialize(modelS);
            candidator = this.InstantZeros.getCandidator();
            %
            %
            % Sampling with identification
            function sample = samplerS()
                % Loop until a valid sample-candidate is found, there is no
                % limit on the number of reduced-form candidates generated; it
                % can be infinite in the worst case.
                %
                % * Step 1: Generate a reduced-form sample.
                %
                % * Step 2: If the tests involve the shock estimates (SHKEST, SHKCONT),
                % precompute the residuals for the reduced-form sample and data.
                %
                % * Step 3: Pre-factor the reduced-form covarince matrix
                % Sigma-->P
                %
                while true
                    %
                    %
                    % Step 1:
                    % Get a reduced-form sample and prepare for identification
                    sample = reducedFormSampler();
                    identificationDraw = identificationDrawer(sample);
                    sample.IdentificationDraw = identificationDraw;
                    %
                    %
                    % Step 2:
                    % Precompute residuals if needed
                    if has.SHKEST
                        draw = historyDrawer(sample);
                        if numSeparableUnits == 1
                            % All models except separable factor models
                            % longY4Resid is needed for factor models.
                            longY4Resid = modelR.getLongY4Resid(longY, sample);
                            U = system.calculateResiduals( ...
                                draw.A, draw.C, longY4Resid, longX ...
                                , hasIntercept=hasIntercept ...
                                , order=meta.Order ...
                            );
                        else
                            % Separable factor models
                            U = nan(numShortPeriods, numSeparableResiduals, numSeparableUnits);
                            for unit = 1 : numSeparableUnits
                                unitA = system.extractUnitFromCellArray(draw.A, unit, EXTRACT_DIM);
                                unitC = system.extractUnitFromCellArray(draw.C, unit, EXTRACT_DIM);
                                unitLongY = system.extractUnitFromNumericArray(longY, unit, EXTRACT_DIM);
                                unitLongY = modelR.getLongY4Resid(unitLongY, sample);
                                U(:, :, unit) = system.calculateResiduals( ...
                                    unitA, unitC, unitLongY, longX ...
                                    , hasIntercept=hasIntercept ...
                                    , order=meta.Order ...
                                );
                            end
                        end
                    end
                    this.SampleCounter = this.SampleCounter + 1;
                    %
                    %
                    Sigma = identificationDraw.Sigma;
                    Sigma = (Sigma + pagetranspose(Sigma))/2;
                    %
                    %
                    sample.D = nan([size(Sigma), numSeparableUnits]);
                    success = false(1, numSeparableUnits);
                    for unit = 1 : numSeparableUnits
                        unitA = draw.A;
                        if numSeparableUnits > 1
                            unitA = system.extractUnitFromCellArray(unitA, unit, EXTRACT_DIM);
                        end
                        %
                        %
                        % Step 3:
                        % Pre-factor the reduced-form covariance matrix; do it
                        % only within the separable loop since the loop can end
                        % prematurely if no suitable candidate is found for a
                        % given sample within a separable unit. Precomputing P
                        % for all separable units would be then a waste of time.
                        unitP = chol(Sigma(:, :, unit));
                        unitU = U(:, :, unit);
                        %
                        %
                        % Step 4:
                        % Make a total of MaxCandidates identification attempts
                        % by rotating the factorized covariance matrix,
                        % evaluating the system properties, and verifying the
                        % restrictions.
                        [D, unitSuccess, attempts] = attemptIdentification_(unitA, unitP, unitU, has, candidator, testFunc, this.MaxCandidates);
                        this.CandidateCounter = this.CandidateCounter + attempts;
                        success(unit) = all(unitSuccess);
                        %
                        %
                        % If the identification attempts are not successful,
                        % break here and proceed to generating a new
                        % reduced-form sample.
                        if ~success(unit)
                            break
                        end
                        %
                        %
                        % If successful, store the identified D matrix.
                        sample.D(:, :, unit) = D;
                    end % for unit
                    %
                    %
                    % If all units were successfully identified, complete
                    % the sample. Otherwise, generate a new reduced-form
                    % sample.
                    if all(success)
                        return
                    end
                end % while
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%


        function addInstantZeros(this, inputs)
            if ~isempty(inputs.InstantZeros)
                this.InstantZeros = inputs.InstantZeros;
                return
            end
            if ~isempty(inputs.InstantZerosTable)
                this.InstantZeros = identifier.InstantZeros(inputs.InstantZerosTable);
                return
            end
        end%


        function addSignRestrictions(this, model)
            tbl = this.IneqRestrictTable;
            if isempty(tbl)
                return
            end
            tablex.validateSignRestrictions(tbl, model=model);
            addTestStrings = identifier.testStringsFromIneqRestrictTable(tbl, model);
            addTestStrings = reshape(unique(string(addTestStrings), "stable"), [], 1);
            this.TestStrings = [this.TestStrings; addTestStrings];
        end%

    end

end




function [D, success, counter] = attemptIdentification_(A, P, U, has, candidator, testFunc, maxAttempts)
    %[
    propertyValues = struct();
    counter = 0;
    while counter < maxAttempts
        %
        % Generate a candidate D based on the factor matrix P; the candidate can
        % either be a simple rotation, or a rotation based on instant zero
        % restrictions.
        D = candidator(P);
        counter = counter + 1;
        %
        %
        % Update the individual system properties for the new candidate matrix
        % D; only update those that are actually needed for the tests.
        if has.SHKRESP
            propertyValues.SHKRESP = system.filterPulses(A, D);
        end
        %
        if has.FEVD
            propertyValues.FEVD = system.finiteFEVD(propertyValues.SHKRESP);
        end
        %
        if has.SHKEST
            % residuals = shocks * D => shocks = residuals / D
            propertyValues.SHKEST = U / D;
        end
        %
        if has.SHKCONT
            propertyValues.SHKCONT = system.contributionsShocks(A, D, propertyValues.SHKEST);
        end
        %
        %
        % Run all the test functions at once.
        success = testFunc(propertyValues);
        if all(success)
            return
        end
        %
        %
        % If failed, Try flipping the signs of the shocks one by one.
        numSuccess = nnz(success);
        for i = 1 : size(D, 1)
            %
            % Store copies of the current state for a possible
            % reversal
            numSuccess0 = numSuccess;
            D0 = D;
            propertyValues0 = propertyValues;
            %
            %
            % Flip sign for the i-th shock
            % The cost of ANY abstraction here is extremely
            % high. Inline everything for quasi-optimal
            % performance.
            D(i, :) = -D(i, :);
            %
            if has.SHKRESP
                propertyValues.SHKRESP(:, :, i) = -propertyValues.SHKRESP(:, :, i);
            end
            %
            if has.SHKEST
                propertyValues.SHKEST(:, i) = -propertyValues.SHKEST(:, i);
            end
            %
            %
            % Evaluate the tests again with a flipped sign for
            % the i-th shock
            success = testFunc(propertyValues);
            if all(success)
                return
            end
            %
            numSuccess = nnz(success);
            %
            % Keep the flipped sign only if it improves the number of
            % successful tests; otherwise, revert to the
            % original sign in the i-th shock
            if numSuccess > numSuccess0
                % Keep the flipped sign if improvement
                % Do nothing
            else
                % Revert to the original sign if no improvement
                numSuccess = numSuccess0;
                D = D0;
                propertyValues = propertyValues0;
            end % if
        end % for i
    end % while
    %]
end%
