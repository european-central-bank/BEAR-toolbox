
classdef ReducedForm ...
    < matlab.mixin.Copyable ...
    & base.PresampleMixin ...
    & base.TabulateMixin

    properties
        Meta
        DataHolder
        Estimator
        Dummies (1, :) cell = cell.empty(1, 0)
    end


    properties
        Presampled (1, :) cell = cell.empty(1, 0)
    end


    properties (Dependent)
        Sampler
        IdentificationDrawer
        HistoryDrawer
        ConditionalDrawer
        UnconditionalDrawer

        SampleCounter
        CandidateCounter

        HasDummies
        NumDummies
    end


    methods

        function this = ReducedForm(options)
            arguments
                options.Meta = [] %(1, 1) base.Meta = base.Meta()
                options.DataHolder = [] %(1, 1) base.DataHolder = base.DataHolder()
                options.Estimator = [] %(1, 1) base.Estimator = base.Estimator()
                %
                options.Dummies (1, :) cell = cell.empty(1, 0)
            end
            %
            this.Meta = options.Meta;
            this.DataHolder = options.DataHolder;
            this.Estimator = options.Estimator;
            if isempty(this.Estimator)
                return
            end
            %
            if ~isempty(options.Dummies)
                if ~this.Estimator.CanHaveDummies
                   error("This reduced-form estimator does not support dummies.");
                end
                this.Dummies = options.Dummies;
            end
        end%

        function initialize(this, varargin)
            longYX = this.getLongYX();
            dummiesYLX = this.generateDummiesYLX(longYX);
            estimator = this.Estimator;
            this.Estimator.initialize(this.Meta, longYX, dummiesYLX, varargin{:});
        end%

        function deinitialize(this)
            this.Estimator.deinitialize();
        end%

        function [allDummiesYLX, indivDummiesYLX] = generateDummiesYLX(this, longYLX)
            indivDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                indivDummiesYLX{i} = this.Dummies{i}.generate(this.Meta, longYLX);
            end
            allDummiesYLX = this.Meta.createEmptyYLX();
            allDummiesYLX = system.mergeDataCells(allDummiesYLX, indivDummiesYLX{:});
        end%

        function resetPresampled(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
            end
            this.Presampled = cell(1, numToPresample);
        end%

        function storePresampled(this, index, sample)
            this.Presampled{index} = sample;
        end%

        function longYX = getLongYX(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longYX = this.getSomeYX(longSpan);
        end%

        function shortYX = getShortYX(this)
            shortYX = this.getSomeYX(this.Meta.ShortSpan);
        end%

        function initYX = getInitYX(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            initSpan = datex.initSpanFromShortSpan(shortSpan, this.Meta.Order);
            initYX = this.getSomeYX(initSpan);
        end%

        function someYX = getSomeYX(this, span)
            someYX = this.DataHolder.getYX(span=span);
        end%

        function someX = getSomeX(this, span)
            someX = this.DataHolder.getX(span=span);
        end%

        function sampler = getSampler(this)
            sampler = this.Estimator.Sampler;
        end%

        function [forecaster, tabulator] = prepareForecaster(this, shortFcastSpan, options)
            arguments
                this
                shortFcastSpan (1, :) datetime
                options.StochasticResiduals
                options.IncludeInitial
            end
            %
            VARIANT_DIM = 3;
            meta = this.Meta;
            fcastStart = shortFcastSpan(1);
            fcastEnd = shortFcastSpan(end);
            this.checkForecastSpan(fcastStart, fcastEnd);
            forecastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortFcastSpan);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            longYX = this.getSomeYX(longFcastSpan);
            %
            outNames = this.getForecastNames();
            order = meta.Order;
            numX = meta.NumExogenousNames;
            %
            %
            function [shortY, shortU, initY, shortX, draw] = forecaster__(sample)
                meta = this.Meta;
                [shortY, shortU, initY, shortX, draw] = this.forecast4S( ...
                    sample, longYX, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=order ...
                );
            end%
            %
            %
            function outTable = tabulator__(shortY, shortU, initY, shortX)
                numPresampled = numel(shortY);
                shortY = cat(VARIANT_DIM, shortY{:});
                shortU = cat(VARIANT_DIM, shortU{:});
                shortX = cat(VARIANT_DIM, shortX{:});
                outData = [shortY, shortU, shortX];
                if options.IncludeInitial
                    initY = cat(VARIANT_DIM, initY{:});
                    outSpan = longFcastSpan;
                    numResiduals = size(shortU, 2);
                    order = size(initY, 1);
                    initU = nan(order, numResiduals, numPresampled);
                    initX = nan([order, numX, numPresampled]);
                    initData = [initY, initU, initX];
                    outData = [initData; outData];
                else
                    outSpan = shortFcastSpan;
                end
                outTable = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=VARIANT_DIM);
            end%
            %
            forecaster = @forecaster__;
            tabulator = @tabulator__;
        end%


        function varargout = forecast(this, fcastSpan, options)
            arguments
                this
                fcastSpan (1, :) datetime
                options.StochasticResiduals (1, 1) logical = true
                options.IncludeInitial (1, 1) logical = true
            end
            %
            if this.NumPresampled == 0
                error("No presampled draws available in this model object.");
            end
            %
            fcastSpan = datex.ensureSpan(fcastSpan);
            %
            [forecaster, tabulator] = this.prepareForecaster( ...
                fcastSpan, ...
                stochasticResiduals=options.StochasticResiduals, ...
                includeInitial=options.IncludeInitial ...
            );
            %
            numPresampled = this.NumPresampled;
            shortY = cell(1, numPresampled);
            shortU = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            shortX = cell(1, numPresampled);
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [shortY{i}, shortU{i}, initY{i}, shortX{i}] = forecaster(sample);
            end

            %
            [varargout{1:nargout}] = tabulator(shortY, shortU, initY, shortX);
        end%


        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longYX, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYX (1, 2) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                %
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            %
            meta = this.Meta;
            order = options.Order;
            hasIntercept = options.HasIntercept;
            %
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            %
            [longY, longX] = longYX{:};
            shortX = longX(order+1:end, :);
            %
            numSeparableUnits = meta.NumSeparableUnits;
            shortY = cell(1, numSeparableUnits);
            shortU = cell(1, numSeparableUnits);
            initY = cell(1, numSeparableUnits);
            EXTRACT_DIM = 3;
            for unit = 1 : numSeparableUnits
                unitSigma = system.extractUnitFromCellArray(draw.Sigma, unit, EXTRACT_DIM);
                unitA = system.extractUnitFromCellArray(draw.A, unit, EXTRACT_DIM);
                unitC = system.extractUnitFromCellArray(draw.C, unit, EXTRACT_DIM);
                %
                % Generate residuals
                unitShortU = system.generateResiduals( ...
                    unitSigma, stochasticResiduals=options.StochasticResiduals ...
                );
                %
                % Extract initial conditions
                unitLongY = system.extractUnitFromNumericArray(longY, unit, EXTRACT_DIM);
                unitInitY = this.getInitY(unitLongY, order, sample, forecastStartIndex);
                %
                % Calculate forecast
                unitShortY = system.forecast( ...
                    unitA, unitC, unitInitY, shortX, unitShortU ...
                    , hasIntercept=hasIntercept ...
                );
                %
                shortU{unit} = unitShortU;
                initY{unit} = unitInitY;
                shortY{unit} = unitShortY;
            end
            %
            CAT_DIM = 2;
            shortY = cat(CAT_DIM, shortY{:});
            shortU = cat(CAT_DIM, shortU{:});
            initY = cat(CAT_DIM, initY{:});
        end%

    end

    methods (Access = public)
        function initY = getInitY(this, longY, order, ~, ~)
            % Superclass uses longY and order only
            initY = longY(1:order, :);
        end%

        function longY = getLongY4Resid(this, longY, ~)
        end%

        function forecastNames = getForecastNames(this)
            meta = this.Meta;
            forecastNames = [ ...
                meta.PseudoEndogenousNames, ...
                meta.ResidualNames, ...
                meta.ExogenousNames, ...
            ];
        end%
    end


    methods
        function out = getMeta(this)
            out = this.Meta;
        end%

        function out = get.IdentificationDrawer(this)
            out = this.Estimator.IdentificationDrawer;
        end%

        function out = get.Sampler(this)
            out = this.Estimator.Sampler;
        end%

        function out = get.SampleCounter(this)
            out = this.Estimator.SampleCounter;
        end%

        function out = get.CandidateCounter(this)
            out = NaN;
        end%

        function out = get.HistoryDrawer(this)
            out = this.Estimator.HistoryDrawer;
        end%

        function out = get.ConditionalDrawer(this)
            out = this.Estimator.ConditionalDrawer;
        end%

        function out = get.UnconditionalDrawer(this)
            out = this.Estimator.UnconditionalDrawer;
        end%

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
        end%
    end


    methods

        function varargout = estimateResiduals(this, varargin)
            meta = this.Meta;
            longYX = this.getLongYX();
            %
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateResiduals4S(sample, longYX);
            end%
            %
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @nan, ...
                "dimNames", {meta.ResidualNames}, ...
                "progressMessage", "Estimating residuals", ...
                options{:} ...
            );
        end%

        function [shortU, sample] = estimateResiduals4S(this, sample, longYX)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            [longY, longX] = longYX{:};
            %
            numSeparableUnits = meta.NumSeparableUnits;
            shortU = cell(1, numSeparableUnits);
            %
            EXTRACT_DIM = 3;
            for unit = 1 : numSeparableUnits
                unitA = system.extractUnitFromCellArray(draw.A, unit, EXTRACT_DIM);
                unitC = system.extractUnitFromCellArray(draw.C, unit, EXTRACT_DIM);
                unitLongY = system.extractUnitFromNumericArray(longY, unit, EXTRACT_DIM);
                unitLongY = this.getLongY4Resid(unitLongY, sample);
                unitShortU = system.calculateResiduals( ...
                    unitA, unitC, unitLongY, longX ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
                shortU{unit} = unitShortU;
            end
            %
            UNIT_DIM = 2;
            shortU = cat(UNIT_DIM, shortU{:});
        end%

        function varargout = calculateResiduals(this, varargin)
            [varargout{1:nargout}] = this.estimateResiduals(varargin{:});
        end%


        function checkForecastSpan(this, fcastStart, fcastEnd)
            beforeStart = datex.shift(fcastStart, -1);
            if ~any(beforeStart == this.Meta.ShortSpan)
                error("Forecast start period out of range.");
            end
            if ~this.Meta.HasExogenous
                return
            end
            if ~any(fcastEnd == this.DataHolder.Span)
                error("Forecast end period out of range.");
            end
        end%

    end

end

