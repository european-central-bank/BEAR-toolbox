
classdef NormalWishartPanel ...
    < separable.Estimator

    properties
        Settings = separable.estimator.settings.NormalWishartPanel()
    end


    properties (Constant)
        Description = "Normal-Wishart panel"
        HasCrossUnits = false
        CanBeIdentified = true
        CanHaveDummies = false
    end


    methods

        function initializeSampler(this, meta, longYX)
            %[
            arguments
                this
                meta
                longYX (1, 2) cell
            end

            [longY, longX] = longYX{:};

            const = meta.HasIntercept;
            numLags = meta.Order;
            numCountries = meta.NumUnits;

            ar = this.Settings.Autoregression;
            lambda1 = this.Settings.Lambda1;
            lambda3 = this.Settings.Lambda3;
            lambda4 = this.Settings.Lambda4;
            priorexo = this.Settings.Exogenous;

            % reshape input endogenous matrix
            % longY = reshape(longY,size(longY,1),numEndog,numCountries);

            % compute preliminary elements
            [X, ~, Y, ~, N, n, m, p, T, k, q]=bear.panel2prelim(longY,longX,const,numLags,cell(numCountries,1));

            % obtain prior elements (from a standard normal-Wishart)
            [B0, beta0, phi0, S0, alpha0]=bear.panel2prior(N,n,m,p,T,k,q,longY,ar,lambda1,lambda3,lambda4,priorexo);

            % obtain posterior distribution parameters
            [Bbar, betabar, phibar, Sbar, alphabar, alphatilde]=bear.nwpost(B0,phi0,S0,alpha0,X,Y,n,N*T,k);

            function sample = sampler()

                % draw B from a matrix-variate student distribution with location Bbar, scale Sbar and phibar and degrees of freedom alphatilde (step 2)
                B=bear.matrixtdraw(Bbar,Sbar,phibar,alphatilde,k,n);

                % then draw sigma from an inverse Wishart distribution with scale matrix Sbar and degrees of freedom alphabar (step 3)
                sigma=bear.iwdraw(Sbar,alphabar);

                sample = struct();
                sample.beta = B(:);
                sample.sigma = sigma(:);

            end

            this.Sampler = @sampler;

            %]
        end%


        function createDrawers(this, meta)
            %[
            numCountries = meta.NumUnits;
            numEndog = meta.NumEndogenousConcepts;
            numRowsA = numEndog*meta.Order;
            numExog = meta.NumExogenousNames+double(meta.HasIntercept);
            numRowsB = numRowsA + numExog;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);

            function [A, C] = betaDrawer(sample, horizon)
                beta = reshape(sample.beta, numRowsB, numEndog);
                A = beta(1:numRowsA,:);
                C = beta(numRowsA+1:end,:);
                A = repmat(A, [1, 1, numCountries]);
                C = repmat(C, [1, 1, numCountries]);
                if horizon > 0
                    A = wrap(A, horizon);
                    C = wrap(C, horizon);
                end
            end%

            function sigma = sigmaDrawer(sample, horizon)
                sigma = reshape(sample.sigma, numEndog, numEndog);
                sigma = repmat(sigma, [1, 1, numCountries]);
                if horizon > 0
                    sigma = wrap(sigma, horizon);
                end
            end%

            function draw = identificationDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, identificationHorizon);
                draw.Sigma = sigmaDrawer(sample, 0);
            end%

            function draw = unconditionalDrawer(sample, startIndex, forecastHorizon)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, forecastHorizon);
                draw.Sigma = sigmaDrawer(sample, forecastHorizon);
            end%

            function draw = historyDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, estimationHorizon);
                draw.Sigma = sigmaDrawer(sample, estimationHorizon);
            end%

            function draw = conditionalDrawer(sample, startIndex, forecastHorizon)
                draw = struct();
                draw.beta = wrap(repmat(sample.beta, 1, 1, numCountries), forecastHorizon);
            end%

            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%

    end

end

