
classdef TabulateMixin < handle

    methods
        function outTbx = tabulateSamples(this, input, options)
        % Tabulate model property across samples
            arguments
                this
                input.Calculator function_handle
                input.Span (1, :) datetime
                input.VariantDim (1, 1) double
                input.Initiator function_handle
                input.DimNames (1, :) cell
                options.IncludeInitial (1, 1) logical = true
                options.Progress (1, 1) logical = true
                options.ProgressMessage (1, 1) string = ""
            end
            %
            meta = this.Meta;
            order = meta.Order;
            numPresampled = this.NumPresampled;
            %
            cellY = cell(1, numPresampled);
            progressMessage = sprintf("%s (%s) [%g]", options.ProgressMessage, this.Estimator.ShortClassName, numPresampled);
            progressBar = progress.Bar(progressMessage, numPresampled, active=options.Progress);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [Y4S, sample] = input.Calculator(sample);
                cellY{i} = Y4S;
                this.Presampled{i} = sample;
                progressBar.increment();
            end
            Y = cat(input.VariantDim, cellY{:});
            %
            numT = size(Y, 1);
            startPeriod = input.Span(1);
            endPeriod = input.Span(end);
            span = datex.span(startPeriod, endPeriod);
            if options.IncludeInitial
                initSize = [order, size(Y, 2), size(Y, 3), size(Y, 4)];
                initY = input.Initiator(initSize);
                Y = [initY; Y];
                span = datex.longSpanFromShortSpan(span, order);
            end
            %
            outNames = input.DimNames{1};
            outTbx = tablex.fromNumericArray(Y, outNames, span, variantDim=input.VariantDim);
            outTbx = tablex.setHigherDims(outTbx, input.DimNames(2:end));
            %]
        end%
    end

end

