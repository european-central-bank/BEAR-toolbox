
classdef (Abstract) PlainDrawersMixin < handle

    methods
        function createDrawers(this, meta)
            %[
            arguments
                this
                meta
            end
            %
            % numBRows = numY * meta.Order + meta.NumExogenousNames + double(meta.HasIntercept);
            numY = meta.NumEndogenousNames;
            order = meta.Order;
            numL = numY * order;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);
            %
            function draw = drawer(sample, horizon)
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                draw = struct();
                draw.A = wrap(A, horizon);
                draw.C = wrap(C, horizon);
                draw.Sigma = wrap(sample.sigma, horizon);
            end%
            %
            function draw = conditionaldrawer(sample, horizon)
                beta = sample.beta;
                draw = struct();
                draw.beta = wrap(beta, horizon);
            end%
            %
            function draw = identificationDrawer(sample)
                horizon = identificationHorizon;
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                draw = struct();
                draw.A = wrap(A, horizon);
                draw.C = wrap(C, horizon);
                draw.Sigma = sample.sigma;
            end%
            %
            this.HistoryDrawer = @(sample) drawer(sample, estimationHorizon);
            this.UnconditionalDrawer = @(sample, start, horizon) drawer(sample, horizon);
            this.ConditionalDrawer = @(sample, start, horizon) conditionaldrawer(sample, horizon);
            this.IdentificationDrawer = @identificationDrawer;
            %
            %]
        end%
    end

end

