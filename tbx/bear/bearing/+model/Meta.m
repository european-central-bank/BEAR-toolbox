
% model.Meta  Meta information about reduced-form and structural models

classdef Meta < matlab.mixin.Copyable

    % Reduced-form model meta information
    properties (SetAccess=protected)
        % Endogenous concepts; the entire names will be created
        % by prepending unit names to endogenous concepts
        EndogenousConcepts (1, :) string

        % Names of units in panel models
        Units (1, :) string = ""

        % Names of exogenous variables
        ExogenousNames (1, :) string %Names of exogenous variables

        % Prefix prepended to residual names
        ResidualPrefix (1, 1) string = "resid"

        % Autoregressive order of the VAR model
        Order (1, 1) double {mustBePositive, mustBeScalarOrEmpty} = 1

        % True if the model includes an intercept (constant) term
        HasIntercept (1, 1) logical

        % Span of fitted data
        ShortSpan
    end


    % Structural model meta information
    properties (SetAccess=protected)
        % Names of structural shock concepts; the entire names
        % will be created by prepending unit names to shock concepts
        ShockConcepts (1, :) string = string.empty(1, 0)

        % Number of periods for which the VMA
        % representation (shock response matrices) will be drawn
        IdentificationHorizon (1, 1) double = NaN
    end


    % Panel model meta information
    properties (Hidden)
        % True if cross-effects are present in models with multiple units
        HasCrossUnits (1, 1) logical = false
    end


    properties (Constant)
        SEPARATOR = "_"
    end


    properties (Dependent)
        ShortStart
        ShortEnd
        %
        EndogenousNames
        ResidualNames
        HasExogenous
        HasUnits
        ShockNames
        %
        NumEndogenousNames
        NumExogenousNames
        NumEndogenousConcepts
        NumResiduals
        NumShockConcepts
        NumShocks
        NumShockNames
        %
        EstimationSpan
        EstimationStart
        EstimationEnd
        InitSpan
        InitStart
        InitEnd
        LongStart
        LongEnd
        LongSpan
        NumShortSpan
        %
        HasSeparableUnits

        % NumRowsA  Number of rows in the transition matrix
        NumRowsTransition
    end


    methods
        function this = Meta(options)

            arguments
                options.endogenousConcepts (1, :) string {mustBeNonempty}
                options.estimationSpan (1, :) = []
                options.exogenousNames (1, :) string = string.empty(1, 0)
                options.units (1, :) string = ""
                options.order (1, 1) double {mustBePositive, mustBeInteger} = 1
                options.intercept (1, 1) logical = true
                options.shockConcepts (1, :) string = string.empty(1, 0)
                options.shocks (1, :) string = string.empty(1, 0)
                options.identificationHorizon (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
            end
            %
            this.EndogenousConcepts = options.endogenousConcepts;
            %
            this.Units = options.units;
            this.ExogenousNames = options.exogenousNames;
            this.HasIntercept = options.intercept;
            this.Order = options.order;
            %
            if isempty(options.shockConcepts) && ~isempty(options.shocks)
                options.shockConcepts = options.shocks;
            end
            this.populateShockConcepts(options.shockConcepts);
            this.IdentificationHorizon = options.identificationHorizon;
            %
            this.catchDuplicateNames();
            %
            if ~isempty(options.estimationSpan)
                this.ShortSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            end
        end%


        function populateShockConcepts(this, shockConcepts)
            if ~isempty(shockConcepts)
                this.ShockConcepts = shockConcepts;
            else
                this.ShockConcepts = meta.autogenerateShockConcepts(this.NumEndogenousConcepts);
            end
            if this.NumShockNames ~= this.NumEndogenousNames
                error("Number of shock names must match number of endogenous variables");
            end
        end%


        function longYXZ = getLongYXZ(this, varargin)
            longYXZ = this.getSomeYXZ(@datex.longSpanFromShortSpan, varargin{:});
        end%


        function initYXZ = getInitYXZ(this, varargin)
            initYXZ = this.getSomeYXZ(@datex.initSpanFromShortSpan, varargin{:});
        end%


        function someYXZ = getSomeYXZ(this, someSpanFromShortSpan, dataTable, shortSpan, varargin)
            arguments
                this
                someSpanFromShortSpan (1, 1) function_handle
                dataTable timetable
                shortSpan (1, :) datetime
            end
            arguments (Repeating)
                varargin
            end
            someSpan = someSpanFromShortSpan(shortSpan, this.Order);
            someY = tablex.retrieveData(dataTable, this.EndogenousNames, someSpan, varargin{:});
            someX = tablex.retrieveData(dataTable, this.ExogenousNames, someSpan, varargin{:});
            someZ = [];
            someYXZ = {someY, someX, someZ};
        end%


        function initYXZ = initYXZFromLongYXZ(this, longXYZ)
            arguments
                this
                longXYZ (1, 3) cell
            end
            initYXZ = {
                this.initDataFromLongData(longXYZ{1}) ...
                , this.initDataFromLongData(longXYZ{2}) ...
                , this.initDataFromLongData(longXYZ{3}) ...
            };
        end%


        function initData = initDataFromLongData(this, longData)
            arguments
                this
                longData (:, :) double
            end
            initData = longData(1:this.Order, :);
        end%


        function initYLX = getInitYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.Variant (1, :) double = 1
            end
            %
            % Create initial condition span
            order = this.Order;
            startPeriod = periods(1);
            initSpan = datex.span( ...
                datex.shift(startPeriod, -order) ...
                ,  datex.shift(startPeriod, -1) ...
            );
            %
            % Call getDataYLX to get initial condition data
            initYLX = this.getDataYLX( ...
                dataTable, initSpan ...
                , variant=options.Variant ...
                , removeMissing=false ...
            );
        end%

        function [YLX, periods] = getDataYLX(this, dataTable, periods, options)
            arguments
                this
                dataTable timetable
                periods (1, :)
                options.RemoveMissing (1, 1) logical = true
                options.Variant (1, :) double = 1
            end
            %
            numPeriods = numel(periods);
            Y = nan(numPeriods, 0);
            L = nan(numPeriods, 0);
            X = nan(numPeriods, 0);
            %
            % LHS array - current endogenous items
            for i = 1:numel(this.EndogenousItems)
                item = this.EndogenousItems{i};
                Y = [Y, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % RHS array - lags of endogenous items
            for lag = 1:this.Order
                for i = 1:numel(this.EndogenousItems)
                    item = this.EndogenousItems{i};
                    L = [L, item.getData(dataTable, periods, variant=options.Variant, shift=-lag)];
                end
            end
            %
            % RHS array - exogenous items
            for i = 1:numel(this.ExogenousItems)
                item = this.ExogenousItems{i};
                X = [X, item.getData(dataTable, periods, variant=options.Variant)];
            end
            %
            % Remove rows with missing observations to prepare the data for
            % estimation
            if options.RemoveMissing
                inxMissing = any(isnan(Y), 2) | any(isnan(L), 2) | any(isnan(X), 2);
                Y(inxMissing, :) = [];
                L(inxMissing, :) = [];
                X(inxMissing, :) = [];
                periods(inxMissing) = [];
            end
            %
            YLX = {Y, L, X};
        end%


        function emptyYLX = createEmptyYLX(this)
            if this.HasCrossUnits
                numY = this.NumEndogenousNames;
                numL = this.NumEndogenousNames * this.Order;
                numPages = 1;
            else
                numY = this.NumEndogenousConcepts;
                numL = this.NumEndogenousConcepts * this.Order;
                numPages = this.getNumUnits();
            end
            numX = double(this.HasIntercept) + this.NumExogenousNames;
            emptyYLX = { ...
                zeros(0, numY, numPages), ...
                zeros(0, numL + numX, numPages), ...
            };
        end%


        function emptyYXZ = createEmptyYXZ(this)
            numY = this.NumEndogenousNames;
            numX = this.NumExogenousNames;
            numZ = 0;
            emptyYXZ = { ...
                zeros(0, numY), ...
                zeros(0, numX), ...
                zeros(0, numZ), ...
            };
        end%


        function A = ayeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
        end%


        function [A, C] = ayeCeeFromSample(this, sample)
            B = reshape(sample{1}, this.SizeB);
            A = B(1:this.SizeA(1), :);
            C = B(this.SizeA(1)+1:end, :);
        end%


        function Sigma = sigmaFromSample(this, sample)
            Sigma = reshape(sample{2}, this.SizeSigma);
        end%


        function system = systemFromSample(this, sample)
            [A, C] = this.ayeCeeFromSample(sample);
            Sigma = reshape(sample{2}, this.SizeSigma);
            system = {A, C, Sigma};
        end%


        function sample = preallocateRedSample(this, numSamples)
            sample = {nan(this.NumelB, numSamples), nan(this.NumelSigma, numSamples)};
        end%


        function dataArray = reshapeCrossUnitData(this, dataArray)
            arguments
                this
                dataArray double
            end
            if ~this.HasSeparableUnits
                return
            end
            dataArray = reshape(dataArray, size(dataArray, 1), [], this.getNumUnits());
        end%


        function unitData = extractUnitFromCells(this, data, unit, opt)
            arguments
                this
                data (:, :) cell
                unit (1, 1) double
                opt.Dim (1, 1) double = NaN
            end
            if ~this.HasSeparableUnits
                unitData = data;
                return
            end
            unitData = cell(size(data));
            ndimsData = ndims(data{1});
            if isnan(opt.Dim), dim = ndimsData; else, dim = opt.Dim; end
            ref = repmat({':'}, 1, ndimsData);
            for i = 1 : numel(data)
                ref{dim} = unit;
                unitData{i} = data{i}(ref{:});
            end
        end%
    end


    methods (Access=protected)
        function catchDuplicateNames(this)
            allNames = [ ...
                this.EndogenousNames, ...
                this.ExogenousNames, ...
                this.ShockNames ...
            ];
            if numel(allNames) ~= numel(unique(allNames))
                nonuniques = textual.nonunique(allNames);
                error("Duplicate model name(s): " + join(nonuniques, ", "));
            end
        end%
    end


    % Reduced-form dependent properties
    methods
        function out = get.EndogenousNames(this)
            out = string.empty(1, 0);
            for unit = this.Units
                out = [out, meta.concatenate(unit, this.EndogenousConcepts)];
            end
        end%

        function out = get.ResidualNames(this)
            if isa(this, 'favar.Meta')
                out = meta.concatenate(this.ResidualPrefix, [this.FactorNames, this.EndogenousNames]);
            else
                out = meta.concatenate(this.ResidualPrefix, [this.EndogenousNames]);
            end
        end%

        function num = get.NumEndogenousNames(this)
            num = this.NumEndogenousConcepts * this.getNumUnits();
        end%

        function num = get.NumExogenousNames(this)
            num = numel(this.ExogenousNames);
        end%

        function num = getNumUnits(this)
            num = numel(this.Units);
        end%

        function num = get.NumEndogenousConcepts(this)
            num = numel(this.EndogenousConcepts);
        end%

        function num = get.NumResiduals(this)
            num = this.NumEndogenousNames;
        end%

        function start = get.ShortStart(this)
            start = this.ShortSpan(1);
        end%

        function out = get.ShortEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.EstimationSpan(this)
            out = this.ShortSpan;
        end%

        function out = get.EstimationStart(this)
            out = this.ShortSpan(1);
        end%

        function out = get.EstimationEnd(this)
            out = this.ShortSpan(end);
        end%

        function out = get.InitSpan(this)
            out = datex.span(this.InitStart, this.InitEnd);
        end%

        function out = get.InitStart(this)
            out = datex.shift(this.ShortSpan(1), -this.Order);
        end%

        function out = get.InitEnd(this)
            out = datex.shift(this.ShortSpan(1), -1);
        end%

        function out = get.LongStart(this)
            out = datex.shift(this.ShortStart, -this.Order);
        end%

        function out = get.LongEnd(this)
            out = this.ShortEnd;
        end%

        function out = get.LongSpan(this)
            out = datex.span(this.LongStart, this.LongEnd);
        end%

        function out = get.NumShortSpan(this)
            out = numel(this.ShortSpan);
        end%

        function out = get.HasExogenous(this)
            out = ~isempty(this.ExogenousNames);
        end%

        function out = get.HasUnits(this)
            out = ~isequal(this.Units, "");
        end%

        function out = get.HasSeparableUnits(this)
            out = this.HasUnits && ~this.HasCrossUnits;
        end%

        function out = getNumSeparableUnits(this)
            if this.HasSeparableUnits
                out = this.getNumUnits();
            else
                out = 1;
            end
        end%
    end


    % Structural dependent properties
    methods
        function out = get.NumShockConcepts(this)
            out = numel(this.ShockConcepts);
        end%

        function out = get.NumShocks(this)
            out = this.getNumUnits() * this.NumShockConcepts;
        end%

        function out = get.NumShockNames(this)
            out = this.NumShocks;
        end%

        function out = get.ShockNames(this)
            out = string.empty(1, 0);
            for unit = this.Units
                out = [out, meta.concatenate(unit, this.ShockConcepts)];
            end
        end%

        function out = getSeparableShockNames(this)
            if this.HasSeparableUnits
                out = this.ShockConcepts;
            else
                out = this.ShockNames;
            end
        end%

        function out = getSeparableEndogenousNames(this)
            if this.HasSeparableUnits
                out = this.EndogenousConcepts;
            else
                out = this.EndogenousNames;
            end
        end%
    end

end

