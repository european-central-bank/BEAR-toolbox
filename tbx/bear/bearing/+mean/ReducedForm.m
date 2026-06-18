
classdef ReducedForm ...
    < base.ReducedForm

    methods

        function someYX = getSomeYX(this, span)
            someYX = this.DataHolder.getYX(span=span);
            meta = this.Meta;
            someYX{2} = meta.getX(span);
        end%


        function [shortY, shortU, initY, shortX ,draw] = forecast4S(this, sample, longYX, forecastStartIndex, forecastHorizon, options)
            
            arguments
                this
                sample
                longYX (1, 2) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                options.hasIntercept (1, 1) logical
                options.StochasticResiduals (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end

            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            shortU = system.generateResiduals( ...
                draw.Sigma ...
                , stochasticResiduals=options.StochasticResiduals ...
            );

            [shortY, initY] = system.forecastMA( ...
                draw.A, draw.C, longYX, shortU ...
                , order=options.Order ...
            );

            nc = size(shortY, 1);
            shortX = zeros(nc, 0);
            
        end%

    end


    methods (Access=public)

        function outData = assembleOutData(this, initY, initU, ~, shortY, shortU, ~)
            if isempty(initY)
                outData = [shortY, shortU];
            else
                outData = [[initY, initU]; [shortY, shortU]];
            end
        end%

        function forecastNames = getForecastNames(this)
            meta = this.Meta;
            forecastNames = [ ...
                meta.PseudoEndogenousNames, ...
                meta.ResidualNames, ...
            ];
        end%

    end

end

