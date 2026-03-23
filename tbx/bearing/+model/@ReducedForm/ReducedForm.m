
classdef ReducedForm ...
    < handle ...
    & model.PresampleMixin ...
    & model.TabulateMixin

    properties
        Meta
        DataHolder
        Dummies (1, :) cell = cell.empty(1, 0)
        Estimator
    end


    properties
        Presampled (1, :) cell = cell.empty(1, 0)
        ExogenousMean (1, :) double
    end


    properties (Dependent)
        HasDummies (1, 1) logical
        NumDummies (1, 1) double

        Sampler
        IdentificationDrawer
        HistoryDrawer
        ConditionalDrawer
        UnconditionalDrawer

        SampleCounter
        CandidateCounter
    end


    methods

        function this = ReducedForm(options)
            arguments
                options.Meta (1, 1) model.Meta
                options.DataHolder (:, :) model.DataHolder
                options.Estimator (1, 1) estimator.Base
                options.Dummies (1, :) cell = cell.empty(1, 0)
                options.StabilityThreshold % Legacy
            end
            %
            this.Meta = options.Meta;
            this.DataHolder = options.DataHolder;
            this.Dummies = options.Dummies;
            this.Estimator = options.Estimator;
            this.Meta.HasCrossUnits = this.Estimator.HasCrossUnits;
            %
            this.checkConsistency();
            %
            this.resolveEstimationSpan();
        end%


        function checkConsistency(this)
            if ~this.Estimator.CanHaveDummies && ~isempty(this.Dummies)
                error("Estimator does not support dummies, but dummies are provided.");
            end
        end%


        function resolveEstimationSpan(this)
            emptyMetaSpan = isempty(this.Meta.ShortSpan);
            emptyDataHolderSpan = isempty(this.DataHolder.ShortEstimationSpan);
            if emptyMetaSpan && emptyDataHolderSpan
                error("No estimation span provided in Meta or DataHolder.");
            end
            if ~emptyMetaSpan && ~emptyDataHolderSpan
                if ~isequal(this.Meta.ShortSpan, this.DataHolder.ShortEstimationSpan)
                    error("Inconsistent estimation spans in Meta and DataHolder.");
                end
            end
            if emptyMetaSpan
                this.Meta.ShortSpan = this.DataHolder.ShortEstimationSpan;
            end
            if emptyDataHolderSpan
                this.DataHolder.ShortEstimationSpan = this.Meta.ShortSpan;
            end
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


        function longYXZ = getLongYXZ(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            longSpan = datex.longSpanFromShortSpan(shortSpan, this.Meta.Order);
            longYXZ = this.getSomeYXZ(longSpan);
        end%


        function shortYXZ = getShortYXZ(this)
            shortYXZ = this.getSomeYXZ(this.Meta.ShortSpan);
        end%


        function initYXZ = getInitYXZ(this, shortSpan)
            if nargin < 2
                shortSpan = this.Meta.ShortSpan;
            end
            initSpan = datex.initSpanFromShortSpan(shortSpan, this.Meta.Order);
            initYXZ = this.getSomeYXZ(initSpan);
        end%


        function someYXZ = getSomeYXZ(this, span)
            someYXZ = this.DataHolder.getYXZ(span=span);
            someYXZ{1} = this.Meta.reshapeCrossUnitData(someYXZ{1});
        end%


        % function [longYXZ, dummiesYLX, indivDummiesYLX] = initialize(this)
        function initialize(this)
            % initialize  Initialize the reduced-form model estimator
            %
            shortSpan = this.Meta.ShortSpan;
            longYXZ = this.getLongYXZ();
            this.estimateExogenousMean(longYXZ);
            [dummiesYLX, indivDummiesYLX] = this.generateDummiesYLX(longYXZ);
            this.Estimator.initialize(this.Meta, longYXZ, dummiesYLX);
        end%


        function estimateExogenousMean(this, longYXZ)
            [~, longX, ~] = longYXZ{:};
            this.ExogenousMean = mean(longX, 1, "omitNaN");
        end%


        % function ameanY = asymptoticMean(this)
        %     % TODO: Reimplement for time-varying models
        %     this.resetPresampledIndex();
        %     numPresampled = this.NumPresampled;
        %     ameanX = this.ExogenousMean;
        %     ameanY = nan(1, this.Meta.NumLhsColumns, numPresampled);
        %     for i = 1 : numPresampled
        %         redSystem = this.nextPresampledSystem();
        %         ameanY(1, :, i) = reshape(system.asymptoticMean(redSystem, ameanX), [], 1);
        %     end
        %     rows = missing;
        %     ameanY = tablex.fromNumericArray( ...
        %         ameanY, this.Meta.EndogenousNames, rows, variantDim=3 ...
        %     );
        % end%


        function [allDummiesYLX, indivDummiesYLX] = generateDummiesYLX(this, longYLX)
            indivDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                indivDummiesYLX{i} = this.Dummies{i}.generate(this.Meta, longYLX);
            end
            allDummiesYLX = this.Meta.createEmptyYLX();
            allDummiesYLX = system.mergeDataCells(allDummiesYLX, indivDummiesYLX{:});
        end%


        function sampler = getSampler(this)
            sampler = this.Estimator.Sampler;
        end%


        function out = getSystemSampler(this)
            sampler = this.getSampler();
            %
            meta = this.Meta;
            function [system, sample] = systemSampler()
                sample = sampler();
                system = meta.systemFromSample(sample);
            end%
            %
            out = @systemSampler;
        end%


        function [forecaster, tabulator] = prepareForecaster(this, shortFcastSpan, options)
            arguments
                this
                shortFcastSpan (1, :) datetime
                options.StochasticResiduals
                options.IncludeInitial
            end
            %
            variantDim = 3;
            meta = this.Meta;
            fcastStart = shortFcastSpan(1);
            fcastEnd = shortFcastSpan(end);
            this.checkForecastSpan(fcastStart, fcastEnd);
            forecastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortFcastSpan);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            longYXZ = this.getSomeYXZ(longFcastSpan);
            outNames = [meta.EndogenousNames, meta.ResidualNames, meta.ExogenousNames];
            numX = meta.NumExogenousNames;
            order = meta.Order;
            %
            function [shortY, shortU, initY, shortX, draw] = forecaster__(sample)
                [shortY, shortU, initY, shortX, draw] = this.forecast4S( ...
                    sample, longYXZ, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end%
            %
            function outTable = tabulator__(shortY, shortU, initY, shortX)
                numPresampled = numel(shortY);
                shortY = cat(variantDim, shortY{:});
                shortU = cat(variantDim, shortU{:});
                shortX = cat(variantDim, shortX{:});
                if options.IncludeInitial
                    outSpan = longFcastSpan;
                    initY = cat(variantDim, initY{:});
                    initU = nan(size(initY));
                    initX = nan([order, numX, numPresampled]);
                    outData = [[initY, initU, initX]; [shortY, shortU, shortX]];
                else
                    outSpan = shortFcastSpan;
                    outData = [shortY, shortU, shortX];
                end
                %
                outTable = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=variantDim);
            end%
            %
            forecaster = @forecaster__;
            tabulator = @tabulator__;
        end%


        function varargout = forecast(this, fcastSpan, options)
            arguments
                this
                fcastSpan (1, :) datetime
                options.StochasticResiduals (1, 1) logical = false
                options.IncludeInitial (1, 1) logical = false
            end
            %
            fcastSpan = datex.ensureSpan(fcastSpan);
            [forecaster, tabulator] = this.prepareForecaster( ...
                fcastSpan, ...
                stochasticResiduals=options.StochasticResiduals, ...
                includeInitial=options.IncludeInitial ...
            );
            %
            numPresampled = this.NumPresampled;
            shortY = cell(1, numPresampled);
            shortX = cell(1, numPresampled);
            shortU = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [shortY{i}, shortU{i}, initY{i}, shortX{i}] = forecaster(sample);
            end
            
            [varargout{1:nargout}] = tabulator(shortY, shortU, initY, shortX);
        end%


        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longYXZ, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYXZ (1, 3) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                %
                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            %
            meta = this.Meta;
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            numUnits = meta.getNumSeparableUnits();
            shortY = cell(1, numUnits);
            shortU = cell(1, numUnits);
            initY = cell(1, numUnits);
            shortX = [];
            for i = 1 : numUnits
                %
                % Extract unit-specific data
                %
                unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i, dim=3), longYXZ(2), longYXZ(3)];
                unitSigma = meta.extractUnitFromCells(draw.Sigma, i, dim=3);
                unitA = meta.extractUnitFromCells(draw.A, i, dim=3);
                unitC = meta.extractUnitFromCells(draw.C, i, dim=3);
                %
                % Generate unit-specific residuals
                %
                shortU{i} = system.generateResiduals( ...
                    unitSigma ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                %
                % Run unit-specific forecast
                %
                [shortY{i}, initY{i}, shortX] = system.forecast( ...
                    unitA, unitC, unitYXZ, shortU{i} ...
                    , hasIntercept=options.HasIntercept ...
                    , order=options.Order ...
                );
            end
            %
            UNIT_DIM = 2;
            shortY = cat(UNIT_DIM, shortY{:});
            shortU = cat(UNIT_DIM, shortU{:});
            initY = cat(UNIT_DIM, initY{:});
        end%

    end


    methods
        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
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

        function varargout = estimateResiduals(this, varargin)
            meta = this.Meta;
            longYXZ = this.getLongYXZ();
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.calculateResiduals4S(sample, longYXZ);
            end%
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @nan, ...
                "dimNames", {meta.ResidualNames}, ...
                options{:} ...
            );
        end%

        function [u, sample] = calculateResiduals4S(this, sample, longYXZ)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            numUnits = meta.getNumSeparableUnits();
            u = cell(1, numUnits);
            for i = 1 : numUnits
                % unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i), longYXZ(2), longYXZ(3)];
                unitY = meta.extractUnitFromCells(longYXZ{1}, i);
                unitX = longYXZ{2};
                unitA = meta.extractUnitFromCells(draw.A, i);
                unitC = meta.extractUnitFromCells(draw.C, i);
                u{i} = system.calculateResiduals( ...
                    unitA, unitC, unitY, unitX, ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end
            u = cat(2, u{:});
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

