
classdef DataHolder ...
    < matlab.mixin.Copyable

    properties
        Span
        Endogenous
        Exogenous
    end


    methods

        function this = DataHolder(meta, dataTable, varargin)
            arguments
                meta (1, 1) base.Meta = base.Meta()
                dataTable (:, :) timetable = timetable()
            end
            arguments (Repeating)
                varargin
            end
            if ~isempty(dataTable)
                this.Span = tablex.span(dataTable);
                this.Endogenous = tablex.retrieveData(dataTable, meta.EndogenousNames, this.Span, varargin{:});
                this.Exogenous = tablex.retrieveData(dataTable, meta.ExogenousNames, this.Span, varargin{:});
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
            startIndex = datex.diff(startPeriod, this.Span(1)) + 1;
            endIndex = datex.diff(endPeriod, this.Span(1)) + 1;
            if startIndex < 1 || startIndex > numel(this.Span)
                error("Start period out of range");
            end
            index = transpose(startIndex : endIndex);
        end%


        function YX = getYX(this, options)
            arguments
                this
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
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            Y(within, :, :) = this.Endogenous(indexWithin, :, :);
            X(within, :, :) = this.Exogenous(indexWithin, :, :);
            YX = {Y, X};
        end%


        function X = getX(this, options)
            arguments
                this
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
            X = nan(numIndex, size(this.Exogenous, 2), size(this.Exogenous, 3));
            within = index >= 1 & index <= numel(this.Span);
            indexWithin = index(within);
            X(within, :, :) = this.Exogenous(indexWithin, :, :);
        end%
    end

end

