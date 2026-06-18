
classdef Cholesky ...
    < identifier.Base ...
    & identifier.InstantMixin

    properties (SetAccess=protected)
        Ordering (1, :) string
        OrderingIndex (1, :) double
        BackorderingIndex (1, :) double
    end


    properties (Dependent)
        HasReordering
    end


    methods
        function whenPairedWithModel(this, modelS)
            meta = modelS.Meta;
            this.populateSeparableNames(meta);
            this.resolveOrdering(meta);
        end%

        function this = Cholesky(options)
            arguments
                options.Ordering (1, :) string = string.empty(1, 0)
            end
            if isequal(options.Ordering, "")
                options.Ordering = string.empty(1, 0);
            end
            if numel(options.Ordering) ~= numel(unique(options.Ordering))
                error("Duplicate names found in the Cholesky ordering.");
            end
            this.Ordering = options.Ordering;
        end%

        function choleskator = getCholeskator(this)
            function P = choleskatorNoReordering(Sigma)
                P = chol(Sigma);
            end%
            %
            orderIndex = this.OrderingIndex;
            backorderIndex = this.BackorderingIndex;
            function P = choleskatorWithReordering(Sigma)
                P = chol(Sigma(orderIndex, orderIndex));
                P = P(:, backorderIndex);
            end%
            %
            if this.HasReordering
                choleskator = @choleskatorWithReordering;
            else
                choleskator = @choleskatorNoReordering;
            end
        end%

        function candidator = getCandidator(this)
            candidator = @(P) P;
        end%

        function resolveOrdering(this, meta)
            this.OrderingIndex = double.empty(1, 0);
            this.BackorderingIndex = double.empty(1, 0);
            if isempty(this.Ordering)
                return
            end
            endogenousNames = meta.SeparableEndogenousNames;
            dict = textual.createDictionary(endogenousNames);
            endogenousNamesReordered = [this.Ordering, setdiff(endogenousNames, this.Ordering, "stable")];
            ordering = [];
            for n = endogenousNamesReordered
                ordering(end+1) = dict.(n);
            end
            [~, backordering] = sort(ordering);
            this.OrderingIndex = ordering;
            this.BackorderingIndex = backordering;
        end%

        function out = get.HasReordering(this)
            out = ~isempty(this.Ordering);
        end%
    end

end

