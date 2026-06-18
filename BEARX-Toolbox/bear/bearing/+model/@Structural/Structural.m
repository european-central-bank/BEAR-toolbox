%{
%
% model.Structural  Class of structural VAR models
%
%}

classdef Structural < handle & model.PresampleMixin & model.TabulateMixin

    properties
        ReducedForm
        Identifier
        Presampled (1, :) cell = cell.empty(1, 0)
    end


    properties (SetAccess = protected)
        PresampledCounter (1, 1) double = 0
    end

    properties (Dependent)
        Meta
        Estimator
        DataHolder
        %
        Sampler
        SampleCounter
        CandidateCounter
        IdentificationDrawer
        HistoryDrawer
        ConditionalDrawer
        UnconditionalDrawer
    end

    methods

        function this = Structural(options)
            arguments
                options.reducedForm (1, 1) model.ReducedForm
                options.identifier (1, 1) identifier.Base
            end
            %
            this.ReducedForm = options.reducedForm;
            this.Identifier = options.identifier;
            this.Identifier.whenPairedWithModel(this);
        end%


        function resetPresampled(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
            end
            this.Presampled = cell(1, numToPresample);
            %this.ReducedForm.resetPresampled(numToPresample);
        end%


        function storePresampled(this, index, sample)
            this.Presampled{index} = sample;
            this.ReducedForm.storePresampled(index, sample);
        end%


        function varargout = initialize(this)
            this.ReducedForm.initialize();
            this.Identifier.initialize(this);
        end%


        function varargout = simulateResponses(this, varargin)
            meta = this.Meta;
            startPeriod = datex.shift(meta.EstimationEnd, 1);
            endPeriod = datex.shift(meta.EstimationEnd, meta.IdentificationHorizon);
            span = datex.span(startPeriod, endPeriod);
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @this.simulateResponses4S, ...
                "span", span, ...
                "variantDim", 4, ...
                "initiator", @zeros, ...
                "dimNames", {meta.EndogenousNames, meta.getSeparableShockNames()}, ...
                options{:} ...
            );
        end%


        function [y, sample] = simulateResponses4S(this, sample)
        % Simulate a numT x numY x numP x numUnits array of responses to
        % structural shocks for a single presampled system
            if ~isfield(sample, "IdentificationDraw")
                sample.IdentificationDraw = this.IdentificationDrawer(sample);
            end
            unitDim = 2;
            meta = this.Meta;
            draw = sample.IdentificationDraw;
            numP = meta.getNumSeparableUnits();
            y = cell(1, numP);
            for i = 1 : numP
                unitA = meta.extractUnitFromCells(draw.A, i, dim=3);
                unitD = sample.D(:, :, i);
                y{i} = system.filterPulses(unitA, unitD);
            end
            y = cat(unitDim, y{:});
        end%


        function [varargout] = estimateShocks(this, varargin)
%{
% # calculateShocks
%
% {==Estimate structural shocks==}
%
%}
            meta = this.Meta;
            longYXZ = this.DataHolder.getYXZ(span=meta.LongSpan);
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateShocks4S(sample, longYXZ);
            end%
            options = [{"includeInitial", false}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @zeros, ...
                "dimNames", {meta.ShockNames}, ...
                options{:} ...
            );
        end%


        function [e, sample] = estimateShocks4S(this, sample, longYXZ)
            u = this.ReducedForm.estimateResiduals4S(sample, longYXZ);
            meta = this.Meta;
            numP = meta.getNumSeparableUnits();
            e = cell(1, numP);
            u = meta.reshapeCrossUnitData(u);
            for i = 1 : numP
                unitD = sample.D(:, :, i);
                unitU = u(:, :, i);
                e{i} = system.shocksFromResiduals(unitU, unitD);
            end
            e = cat(3, e{:});
        end%


        function contribsTbl = calculateContributions(this, options)
            arguments
                this
                options.IncludeInitial (1, 1) logical = true
            end
            meta = this.Meta;
            numPresampled = this.NumPresampled;
            drawer = this.HistoryDrawer;
            longYXZ = this.getLongYXZ();
            order = meta.Order;
            %
            [contributor, contribs] = this.prepareForContributions(meta.ShortSpan, []);
            numUnits = meta.getNumSeparableUnits();
            %
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                draw = drawer(sample);
                shortE = this.estimateShocks4S(sample, longYXZ);
                for j = 1 : numUnits
                    unitYXZ = [meta.extractUnitFromCells(longYXZ(1), j, dim=3), longYXZ(2), longYXZ(3)];
                    unitInitY = unitYXZ{1}(1:order, :, :);
                    shortX = unitYXZ{2}(order+1:end, :, :);
                    unitD = sample.D(:, :, j);
                    unitA = meta.extractUnitFromCells(draw.A, j, dim=3);
                    unitC = meta.extractUnitFromCells(draw.C, j, dim=3);
                    unitShortE = shortE(:, :, j);
                    unitContrib = contributor(unitA, unitC, unitD, unitShortE, shortX, unitInitY);
                    contribs{i} = [contribs{i}, unitContrib];
                end
            end
            contribsTbl = this.tabulateContributions(contribs, meta.ShortSpan);
        end%


        function outTbl = tabulateContributions(this, C, span)
            arguments
                this
                C (1, :) cell
                span (1, :) datetime
            end
            VARIANT_DIM = 4;
            meta = this.Meta;
            outData = cat(VARIANT_DIM, C{:});
            higherDims = {[meta.getSeparableShockNames(), "Exogenous", "Initials"]};
            outTbl = tablex.fromNumericArray( ...
                outData, ...
                meta.EndogenousNames, ...
                span, ...
                variantDim=VARIANT_DIM, ...
                higherDims=higherDims ...
            );
        end%


        function C = calculateShockContributions4S(this, sample, shockEstimates)
            draw = this.HistoryDrawer(sample);
            C = system.contributionsShocks(draw.A, sample.D, shockEstimates);
        end%


        function varargout = calculateFEVD(this, varargin)
            %
            function [fevd, sample] = calculateFEVD4S(sample)
                [vma, sample] = this.simulateResponses4S(sample);
                fevd = system.finiteFEVD(vma);
            end%
            %
            meta = this.Meta;
            startPeriod = datex.shift(meta.EstimationEnd, 1);
            endPeriod = datex.shift(meta.EstimationEnd, meta.IdentificationHorizon);
            span = datex.span(startPeriod, endPeriod);
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculateFEVD4S, ...
                "span", span, ...
                "variantDim", 4, ...
                "initiator", @zeros, ...
                "dimNames", {meta.EndogenousNames, meta.getSeparableShockNames()}, ...
                options{:} ...
            );
        end%

        varargout = forecast(varargin)
        varargout = conditionalForecast(varargin)
        varargout = prepareForContributions(varargin)

        function varargout = asymptoticMean(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.asymptoticMean(varargin{:});
        end%

        function varargout = estimateResiduals(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.estimateResiduals(varargin{:});
        end%

        function varargout = getLongYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getLongYXZ(varargin{:});
        end%

        function varargout = getShortYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getShortYXZ(varargin{:});
        end%

        function varargout = getSomeYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getSomeYXZ(varargin{:});
        end%

        function varargout = getInitYXZ(this, varargin)
            [varargout{1:nargout}] = this.ReducedForm.getInitYXZ(varargin{:});
        end%
    end


    methods
        function out = get.Meta(this)
            out = this.ReducedForm.Meta;
        end%

        function out = get.Estimator(this)
            out = this.ReducedForm.Estimator;
        end%

        function out = get.DataHolder(this)
            out = this.ReducedForm.DataHolder;
        end%

        function out = get.Sampler(this)
            out = this.Identifier.Sampler;
        end%

        function out = get.SampleCounter(this)
            out = this.Identifier.SampleCounter;
        end%

        function out = get.CandidateCounter(this)
            out = this.Identifier.CandidateCounter;
        end%

        function out = get.IdentificationDrawer(this)
            out = this.ReducedForm.IdentificationDrawer;
        end%

        function out = get.HistoryDrawer(this)
            out = this.ReducedForm.HistoryDrawer;
        end%

        function out = get.ConditionalDrawer(this)
            out = this.ReducedForm.ConditionalDrawer;
        end%

        function out = get.UnconditionalDrawer(this)
            out = this.ReducedForm.UnconditionalDrawer;
        end%
    end

end


