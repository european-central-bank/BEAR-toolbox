
classdef (Abstract) PlainFactorDrawersMixin < handle

    methods
        function createDrawers(this, meta)
            %[
            arguments
                this
                meta
            end
            %
            numEn = meta.NumEndogenousNames;
            numPC = meta.NumFactorNames;
            numY = numEn + numPC;
            % numBRows = numY * meta.Order + meta.NumExogenousNames + double(meta.HasIntercept);
            order = meta.Order;
            numL = numY * order;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            %
            function draw = drawer(sample, horizon)
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.A = wrap(A);
                draw.C = wrap(C);
                draw.Sigma = wrap(sample.sigma);
            end%
            function draw = conditionaldrawer(sample, horizon)
                beta = sample.beta;
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.beta = wrap(beta);               
            end%            
            %
            function draw = identificationDrawer(sample)
                horizon = identificationHorizon;
                sample.B = reshape(sample.beta, [], numY);
                A = sample.B(1:numL, :);
                C = sample.B(numL+1:end, :);
                wrap = @(x) repmat({x}, horizon, 1);
                draw = struct();
                draw.A = wrap(A);
                draw.C = wrap(C);
                % draw.L = wrap(L);
                draw.Sigma = sample.sigma;
                % draw.LD = reshape(sample.LD, [], numY);      
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

