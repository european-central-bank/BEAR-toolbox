
classdef MeanAdjusted ...
    < mean.Estimator

    properties
        Settings = mean.estimator.settings.MeanAdjusted()
    end


    properties (Constant)
        Description = "Mean-adjusted models"
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

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda5 = this.Settings.Lambda5;
            opt.f = this.Settings.ScaleUp;

            opt.p = meta.Order;
            ar = this.Settings.Autoregression;

            bounds = meta.Bounds;
            trendCount = meta.NumTrendParams;
            regimes = meta.Regimes;
            numRegimes = meta.NumRegimes;
            estimStart = meta.EstimationSpan(1);
            CMask = meta.CMask;

            opt.bex = this.Settings.BlockExogenous;
            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            [~, ~, ~, L, ~, Y, ~, ~, ~, numEn, ~, p, T , numBRows, sizeB] = ...
                bear.olsvar(longY, [], false, opt.p);

            %variance from univariate OLS for priors
            arvar = bear.arloop(longY, true, opt.p, numEn);

            [beta0, omega0] = bear.ogrmaprior(ar, arvar, opt.lambda1, opt.lambda2, ...
                opt.lambda3, opt.lambda5, numEn, p, numBRows, sizeB, opt.bex, blockexo);

            [psi0, lambda0] = bear.ogrTVEcreatePriorDeterministic(longY, longX, p, ...
                bounds, trendCount, numRegimes, regimes, estimStart, opt.f);

            TVEH = zeros(numEn, sum(trendCount), T + p);    % T × N × K̃

            % Fill in compressed matrix
            for tt = 1:T + p
                X_big_t = kron(eye(numEn), longX(tt, :));
                TVEH(:, :, tt) = X_big_t(:, CMask);
            end

            %% initialize sample
            % invert omega0
            invomega0 = diag(1./diag(omega0));

            % invert lambda0
            invlambda0 = lambda0\eye(length(lambda0));

            % step 2: set initial values
            % set initial values for B, beta and sigma; as no OLS estimates are available, simply set the value as zeros for B and beta, and identity for sigma
            B = zeros(numBRows, numEn);

            % define the initial value for the inverse of sigma: beacause sigma is identity, this is also identity
            invsigma = eye(numEn);

            % preallocate space for the matrix with the equilibrium values
            eq = zeros(T+p, numEn);

            q2 = length(psi0);

            %===============================================================================

            function sample = sampler()
                Ybar = (Y - L*B)';
                Ypsi = bear.vec(Ybar);

                % Initialize Fsimple for the first time period, using L(t+p,:)
                Fsimple = TVEH(:, :, 1 + p);

                % Loop over the lags (k = 2 to p+1)
                for k = 2:p + 1
                    % Get the lagged values using the original L matrix
                    Fsimple = Fsimple - B((k - 2)*numEn + 1:(k - 1)*numEn, :)'...
                        * TVEH(:, :, 1 + p - (k - 1));
                end

                % Now loop over all time periods (t = 2 to T)
                for t = 2:T
                    % Initialize Ftemp for the current time period t, using L(t+p,:)
                    Ftemp = TVEH(:, :, t + p);

                    % Loop over the lags (k = 2 to p+1)
                    for k = 2:p + 1
                        % Apply the lag structure using the original L matrix
                        Ftemp = Ftemp - B((k - 2)*numEn + 1:(k - 1)*numEn, :)' * ...
                            TVEH(:, :, t + p - (k - 1));
                    end

                    % Stack Fsimple for all time periods
                    Fsimple = cat(1, Fsimple, Ftemp);
                end

                % Compute invOmega as before
                invOmega = kron(eye(T), invsigma);

                % Compute CT and mT as before
                CT = (invlambda0 + Fsimple' * invOmega * Fsimple) \ eye(length(lambda0));
                mT = CT * (Fsimple' * invOmega * Ypsi + invlambda0 * psi0);

                % Draw from the multivariate normal distribution
                theta = mT + chol(bear.nspd(CT), 'lower')*randn(q2, 1);

                % recover equilibrium values from psi
                for it = 1:T + p
                    eq(it, :) = (squeeze(TVEH(:, :, it))*theta)'; % compute the equilibrium values given theta
                end

                % step 4: now that psi/F has been drawn, it is possible to generate Yhat, Lhat and yhat
                temp2 = longY - eq;
                temp3 = bear.lagx(temp2, p);

                Yhat = temp3(:,1:numEn);
                yhat = Yhat(:);
                Lhat = temp3(:,numEn+1:end);

                % step 5: next, at iteration ii, draw sigma from IW, conditional on most recent draw for psi and beta
                % obtain first Stilde
                Stilde = (Yhat - Lhat*B)'*(Yhat - Lhat*B);

                % next draw from IW(Stilde,T)
                sigma = bear.iwdraw(Stilde, T);

                % invert sigma
                C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
                invC = C\speye(numEn);
                invsigma = invC*invC';

                % step 6: finally, at iteration ii, draw beta from a N, conditional on most recent draw for psi and sigma
                % first obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, Lhat'*Lhat);
                C = bear.trns(chol(bear.nspd(invomegabar), 'Lower'));
                invC = C\speye(sizeB);
                omegabar = invC*invC';

                % following, obtain betabar
                betabar = omegabar*(invomega0*beta0 + kron(invsigma, Lhat')*yhat);

                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar),'lower')*randn(sizeB, 1);

                sample.ss = eq(p+1:end,:);

                % reshape to obtain B
                B = reshape(beta, numBRows, numEn);
                sample.A = B;
                gamma_vec_full = zeros(sum(trendCount) * numEn, 1);
                gamma_vec_full(CMask) = theta;
                sample.C = reshape(gamma_vec_full, [], numEn);

                sample.Sigma = sigma;

            end%

            % function A = retriever(sample, t)
            %     A = sample.A;
            % end%
            % 
            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%

        function createDrawers(this, meta)
            %[
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;
            wrap = @(x, horizon) repmat({x}, horizon, 1);

            function [A, C] = betaDrawer(sample, horizon)
                if horizon > 0
                    A = wrap(sample.A, horizon);
                    C = wrap(sample.C, horizon);
                end
            end%

            function Sigma = sigmaDrawer(sample, horizon)
                if horizon > 0
                    Sigma = wrap(sample.Sigma, horizon);
                else
                    Sigma = sample.Sigma;
                end
            end

            function draw = unconditionalDrawer(sample, start, forecastHorizon)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, forecastHorizon);
                draw.Sigma = sigmaDrawer(sample, forecastHorizon);
            end%

            function draw = identificationDrawer(sample)
                draw = struct();
                horizon = identificationHorizon;
                [draw.A, draw.C] = betaDrawer(sample, horizon);
                draw.Sigma = sigmaDrawer(sample, 0);
            end%

            function draw = historyDrawer(sample)
                draw = struct();
                [draw.A, draw.C] = betaDrawer(sample, estimationHorizon);
                draw.Sigma = sigmaDrawer(sample, estimationHorizon);
            end%

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon)
                B = [sample.A; sample.C];
                draw = struct();
                draw.beta = wrap(B(:), forecastHorizon);
            end%

            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;
            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            %]
        end%

    end

end

