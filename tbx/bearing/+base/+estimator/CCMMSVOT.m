
% Stochastic Volatility model with jumps and large shocks
% SV model with outliers and fat tail ("t") distributed shocks, most generic model nr 3 in the CCMM paper

classdef CCMMSVOT ...
    < base.Estimator

    properties
        Settings = base.estimator.settings.CCMMSVOT()
    end


    properties (Constant)
        Description = "CCMM Stochastic volatility with jumps and large shocks"
        Category = "Time-varying estimators"
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

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

            opt.freqO = this.Settings.OutlierFreq;
            opt.PriorYears = this.Settings.PriorObsYears;

            opt.lbDofQ = this.Settings.DoFLowerBound; %3
            opt.ubDofQ = this.Settings.DoFUpperBound; %40

            opt.scalePhi = this.Settings.HeteroskedasticityScale;

            opt.TP = this.Settings.Turningpoint;

            opt.ar = this.Settings.Autoregression;

            %Seting up the priors
            %B and F
            [~, ~, sigmahat, LX, ~, Y, ~, ~, ~, numEn, numEx, ~, estimLength, numBRows, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            [~, Lambdahat] = bear.triangf(sigmahat);
            sbar = diag(Lambdahat);
            Lambda = sparse(diag(sbar));

            [arvar, arEPS]  =  bear.arloop(longY, opt.const, 1, numEn);

            modelfreq = datex.frequency(meta.EstimationStart);

            prior = ...
                largeshockUtils.get_MH_Prior_CCMM(opt, numEn, numBRows, numEx, arvar, modelfreq);

            %Setting up initial values for the loop
            T0LS = find(meta.LongSpan == opt.TP);
            pars.B = bear.olsvar(longY(1:T0LS,:), longX(1:T0LS,:), opt.const, opt.p);

            pars.F = prior.meanF;

            Lambda0 = (arEPS(opt.p:end, :).^2)';
            pars.logLambda = log(Lambda0);

            Phi0 = 0.0001*eye(numEn);
            pars.cholPhi = largeshockUtils.vech(chol(Phi0, "lower"));

            pars.O = ones(numEn, estimLength);
            pars.probO = 0.1*ones(1, numEn)';
            pars.Q = ones(numEn, estimLength);

            function sample  =  sampler()

                pars = largeshockUtils.drawB(pars, prior, numEn, sizeB, ...
                    numBRows, estimLength, Y, LX);
                pars = largeshockUtils.drawF(pars, prior, numEn, Y, LX);
                pars = largeshockUtils.drawLogLambdaSVOT(pars, prior, numEn, estimLength, Y, LX);
                pars = largeshockUtils.drawPhi(pars, prior, numEn, estimLength);

                sample = pars;
                sample.F = largeshockUtils.unvech(pars.F, 0, 1);
                H = largeshockUtils.get_H(pars);
                sample.sigmaAvg = sample.F * Lambda * sample.F';

                for kk = 1:estimLength
                   sample.sigma_t{kk, 1} = sample.F * diag(H(:,kk)) * sample.F';
                end

            end

            this.Sampler = @sampler;

            %]
        end%


        function createDrawers(this, meta)
            %[

            %sizes
            numEn = meta.NumEndogenousNames;
            numARows = numEn * meta.Order;
            numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;


            function draw = unconditionalDrawer(sample, startingIndex, forecastHorizon)

                % reshape it to obtain B
                B = sample.B;

                % draw F from its posterior distribution
                F = sparse(sample.F(:,:));

                % step 4: draw phi and gamma from their posteriors
                cholphi = largeshockUtils.unvech(sample.cholPhi);
                lambda =  sample.logLambda(:, startingIndex-1);

                draw.Sigma = cell(forecastHorizon, 1);

                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);
                draw.A = repmat({A}, forecastHorizon, 1);
                draw.C = repmat({C}, forecastHorizon, 1);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods estimLength+1 to estimLength+h
                for jj = 1:forecastHorizon

                    n = length(lambda);
                    z = randn(n, 1);         % standard normal column vector
                    error = cholphi * z;     % apply Cholesky to get desired covariance
                    lambda = lambda + error;

                    % obtain Lambda_t
                    Lambda = sparse(diag(exp(lambda)));

                    % recover sigma_t and draw the residuals
                    draw.Sigma{jj, 1}(:, :) = full(F * Lambda * F');
                end
            end

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )

                beta = sample.B(:);
                draw.beta = repmat({beta}, forecastHorizon, 1);

            end%


            function draw = identificationDrawer(sample)

                horizon = identificationHorizon;
                % reshape it to obtain B
                B = sample.B;
                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);

                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                draw.Sigma = sample.sigmaAvg;

            end

            function draw = historyDrawer(sample)

                % reshape it to obtain B
                B = sample.B;
                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);
                draw.A = repmat({A}, estimationHorizon, 1);
                draw.C = repmat({C}, estimationHorizon, 1);

                for jj = 1:estimationHorizon
                    draw.Sigma{jj,1}(:, :) = sample.sigma_t{jj, 1}(:, :);
                end

            end%

            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;

            %]
        end%

    end
end
