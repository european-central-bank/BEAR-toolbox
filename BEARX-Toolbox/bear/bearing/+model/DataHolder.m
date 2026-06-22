
classdef DataHolder < handle

    properties
        Span
        Endogenous
        Exogenous

        % LongEstimationSpan  Estimation date span including initial condition periods
        ShortEstimationSpan
    end


    methods

        function this = DataHolder(meta, dataTable, options)
            arguments
                meta (1, 1) model.Meta
                dataTable (:, :) timetable
                options.estimationSpan (1, :) = []
                options.variant (1, 1) double = 1
            end
            %
            this.Span = tablex.span(dataTable);
            this.Endogenous = tablex.retrieveData(dataTable, meta.EndogenousNames, this.Span, variant=options.variant);
            this.Exogenous = tablex.retrieveData(dataTable, meta.ExogenousNames, this.Span, variant=options.variant);
            %
            if ~isempty(options.estimationSpan)
                this.ShortEstimationSpan = datex.span(options.estimationSpan(1), options.estimationSpan(end));
            end
        end%


        function index = getSpanIndex(this, span)
            arguments
                this
                span (1, :) datetime
            end
            if isempty(span)
                index = zeros(0, 1);
                return
            end
            startPeriod = span(1);
            endPeriod = span(end);
            dataStartPeriod = this.Span(1);
            numDataPeriods = numel(this.Span);
            startIndex = datex.diff(startPeriod, dataStartPeriod) + 1;
            endIndex = datex.diff(endPeriod, dataStartPeriod) + 1;
            if startIndex < 1 || startIndex > numDataPeriods
                error("Start period out of data availability span.");
            end
            index = transpose(startIndex : endIndex);
        end%


        function YXZ = getYXZ(this, options)
            arguments
                this
                %
                options.Span (1, :) datetime = []
                options.Index (1, :) double = []
            end
            %
            if ~isempty(options.Index)
                index = options.Index;
            else
                index = this.getSpanIndex(options.Span);
            end
            %
            numIndex = numel(index);
            Y = nan(numIndex, size(this.Endogenous, 2), size(this.Endogenous, 3));
            X = nan(numIndex, size(this.Exogenous, 2), size(this.Exogenous, 3));
            Z = nan(numIndex, 0, 0);
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Y(within, :, :) = this.Endogenous(indexWithin, :, :);
            X(within, :, :) = this.Exogenous(indexWithin, :, :);
            YXZ = {Y, X, Z};
        end%

    end

end

