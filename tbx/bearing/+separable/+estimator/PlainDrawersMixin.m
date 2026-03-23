
classdef (Abstract) PlainDrawersMixin ...
    < matlab.mixin.Copyable

    methods
        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numRowsA = numEndog * meta.Order;
            numExog = meta.NumExogenousNames + double(meta.HasIntercept);
            numRowsB = numRowsA + numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);

            function [A, C] = betaDrawer(sample, horizon)
                beta = sample.beta;
                A = nan(numRowsA, numEndog, numCountries);
                C = nan(numExog, numEndog, numCountries);
                for ii = 1 : numCountries
                    temp = reshape(beta(:, ii), numRowsB, numEndog);
                    A(:,:, ii) = temp(1:numRowsA, :);
                    C(:,:, ii) = temp(numRowsA+1:end, :);
                end
                if horizon > 0
                    A = wrap(A, horizon);
                    C = wrap(C, horizon);
                end
            end%

            function Sigma = sigmaDrawer(sample, horizon)
                Sigma = nan(numEndog, numEndog, numCountries);
                for ii = 1 : numCountries
                    Sigma(:, :, ii) = reshape(sample.sigma(:, ii), numEndog, numEndog);
                end
                if horizon > 0
                    Sigma = wrap(Sigma, horizon);
                end
            end

            function draw = unconditionalDrawer(sample, start, forecastHorizon)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, forecastHorizon);
                draw.Sigma = sigmaDrawer(sample, forecastHorizon);
            end%

            function draw = identificationDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, identificationHorizon);
                draw.Sigma = sigmaDrawer(sample, 0);
            end%

            function draw = historyDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, estimationHorizon);
                draw.Sigma = sigmaDrawer(sample, estimationHorizon);
            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon)
                draw = struct();
                draw.beta = wrap(sample.beta, forecastHorizon);
            end%

            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%
    end

end

