
classdef ReducedForm < base.ReducedForm

    methods

        function [shortY, shortU, initY, shortX, draw] = forecast4S(this, sample, longYX, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYX (1, 2) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double

                options.StochasticResiduals (1, 1) logical
                options.HasIntercept (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end

            meta = this.Meta;

            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);

            shortU1 = system.generateResiduals( ...
                draw.Sigma1 ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            shortU2 = system.generateResiduals( ...
                draw.Sigma2 ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            order = options.Order;

            [longY, longX] = longYX{:};
            initY = this.getInitY(longY, order, sample, forecastStartIndex);
            shortX = longX(order+1:end, :);

            %
            % Run forecast
            %
            [shortY, shortU, initY, shortX] = system.forecastTH( ...
                draw.A1, draw.A2, draw.C1, draw.C2, initY, shortX, shortU1, shortU2 ...
                , delay=draw.delay ...
                , threshold=draw.threshold ...
                , thresholdIndex=meta.ThresholdNameIndex ...
                , hasIntercept=options.HasIntercept ...
            );

        end%

    end

end

