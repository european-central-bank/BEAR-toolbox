
% FAVAR verison of time-varying coefficients model
% FAVAR with tvbvar=1 in BEAR5

classdef BetaTVFAVAR ...
    < factorTwostep.Estimator


    properties
        Settings = factorTwostep.estimator.settings.BetaTVFAVAR()
    end


    properties (Constant)
        Description = "Two-step FAVAR with time-varying coefficients"
        Category = "Time-varying factor-augmented estimators"
        HasCrossUnits = false
        CanBeIdentified = true
    end


    methods

        function initializeSampler(this, meta, longYX)
            %[

            arguments
                this
                meta
                longYX (1, 2) cell
            end

            longX = longYX{2};

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            %% FAVAR settings, maybe we can move this to a separate function

            favar = this.FAVAR;
            FY = favar.FY;

            [~, betahat, sigmahat, LX, ~, Y, ~, ~, ~, numY, ~, p, estimLength, ~, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            [arvar] = bear.arloop(FY, opt.const, p, numY);

            [~, y, ~, ~, Xbar] = bear.tvbvarmat(Y, LX, numY, sizeB, estimLength); %create TV matrices
            [chi, psi, kappa, S, H, I_tau] = bear.tvbvar1prior(arvar, numY, sizeB, estimLength);

            % preliminary elements for the algorithm
            % set tau as a large value
            tau = 10000;

            % compute psibar
            chibar = (chi + estimLength) / 2;

            % compute alphabar
            kappabar = estimLength + kappa;

            % step 1: determine initial values for the algorithm

            % initial value Omega
            omega = diag(diag(betahat * betahat'));

            % invert Omega
            invomega = diag(1 ./ diag(omega));

            % initial value for sigma
            sigma = sigmahat;

            % invert sigma
            C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
            invC = C \ speye(numY);
            invsigma = invC * invC';

            %Let's redo X'X and X'Y
            pre_xx = Xbar'*kron(speye(estimLength), ones(numY, numY)) * Xbar;   % like setting invsigma to a matrix of (numY,numY) ones

            pre_xy = NaN(estimLength * sizeB, numY);
            for i = 1:estimLength
                pre_xy(1 + (i - 1) * sizeB:i * sizeB, :) = kron(ones(numY, 1), kron(y(1 + (i - 1) * numY:i * numY)', ...
                    Xbar(1 + numY * (i - 1), 1 + sizeB * (i - 1):sizeB * (i - 1) + sizeB / numY)'));
            end

            LD = favar.L;

            %===============================================================================

            function sample  =  sampler()

                % step 2: draw B
                invomegabar = H' * kron(I_tau, invomega) * H + ...
                    kron(speye(estimLength), kron(invsigma, ones(sizeB / numY, sizeB / numY))) .* pre_xx;

                % compute temporary value
                temp = sum(kron(ones(estimLength, 1), kron(invsigma, ones(sizeB / numY, 1))) .* pre_xy, 2);

                % solve
                Bbar = invomegabar \ temp;

                % simulation phase:
                B = Bbar + chol(invomegabar, 'Lower')' \ randn(sizeB * estimLength, 1);
                % reshape
                Beta = reshape(B, sizeB, estimLength);

                % step 3: draw omega from its posterior
                % compute psibar
                psibar = (1 / tau) * Beta(:, 1).^2 + sum((Beta(:, 2:estimLength) - Beta(:, 1:estimLength - 1)).^2, 2) + psi;

                % draw omega
                omega = diag(arrayfun(@bear.igrandn, kron(ones(sizeB, 1), chibar), psibar / 2));

                % invert it for next iteration
                invomega = diag(1 ./ diag(omega));

                % step 4: draw sigma from its posterior
                %estimate the residuals
                eps = y - Xbar * B;
                Eps = reshape(eps, numY, estimLength);

                % estimate Sbar
                Sbar = Eps * Eps' + S;

                % draw sigma
                sigma = bear.iwdraw(Sbar, kappabar);

                % invert it for next iteration
                C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
                invC = C \ speye(numY);
                invsigma = invC * invC';

                % record phase
                sample.beta = mat2cell(B, repmat(sizeB, estimLength, 1));
                sample.omega = diag(omega);
                sample.sigma = sigma;
                sample.FY = FY;
                sample.LD = LD;
            end

            this.Sampler = @sampler;

            %]
        end%


        function createDrawers(this, meta)
            %[
            numEn = meta.NumEndogenousNames;
            numPC = meta.NumFactorNames;
            numY = numEn + numPC;
            numARows = numY * meta.Order;
            numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;
            sizeB = numY * numBRows;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            function [draw] = unconditionalDrawer(sample, startingIndex, forecastHorizon)

                %draw beta, omega and sigma and F from their posterior distributions

                % draw beta
                beta = sample.beta{startingIndex - 1, 1};

                % draw omega
                omega = sample.omega;

                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));

                draw.A = cell(forecastHorizon, 1);
                draw.C = cell(forecastHorizon, 1);
                draw.Sigma = cell(forecastHorizon, 1);
                Sigma = reshape(sample.sigma, numY, numY);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:forecastHorizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    B = reshape(beta, [], numY);
                    draw.A{jj, 1}(:, :) = B(1:numARows, :);
                    draw.C{jj, 1}(:, :) = B(numARows + 1:end, :);
                    draw.Sigma{jj, 1}(:, :) = Sigma;
                end
            end

            function [draw] = conditionalDrawer(sample, startingIndex, forecastHorizon )

                %draw beta, omega and sigma and F from their posterior distributions

                % draw beta
                beta = sample.beta{startingIndex - 1, 1};

                % draw omega
                omega = sample.omega;

                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));

                draw.beta = cell(forecastHorizon, 1);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:forecastHorizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    draw.beta{jj, 1}(:) = beta;
                end
            end



            function [draw] = identificationDrawer(sample)
                horizon = identificationHorizon;

                %draw beta, omega from their posterior distribution
                % draw beta
                beta = sample.beta{end, 1};

                % draw omega
                omega = sample.omega;

                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));

                draw.A = cell(horizon, 1);
                draw.C = cell(horizon, 1);


                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:horizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    B = reshape(beta, [], numY);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                end

                draw.Sigma = reshape(sample.sigma, numY, numY);
                % draw.LD = reshape(sample.LD, [], numY);
            end%

            function draw = historyDrawer(sample)
                for jj = 1:estimationHorizon
                    B = reshape(sample.beta{jj}, [], numY);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                end
                draw.Sigma = repmat({reshape(sample.sigma, numY, numY)}, estimationHorizon, 1);
            end%

            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;

            %]
        end%

    end

end

