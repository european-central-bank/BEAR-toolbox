
% Bayesian VAR model with time-varying parameters, tvbvar=1 in BEAR5
% Third line

classdef BetaTV ...
    < base.Estimator

    properties
        Settings = base.estimator.settings.BetaTV()
    end


    properties (Constant)
        Description = "Time-varying VAR"
        Category = "Time-varying estimators"
        HasCrossUnits = false
        CanBeIdentified = true
        CanHaveDummies = true
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

            order = meta.Order;
            opt.const = meta.HasIntercept;
            opt.p = order;

            [~, betahat, sigmahat, LX, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            numARows = numEn * order;

            [arvar] = bear.arloop(longY, opt.const, p, numEn);

            [~, y, ~, ~, Xbar] = bear.tvbvarmat(Y, LX, numEn, sizeB, estimLength); %create TV matrices
            [chi, psi, kappa, S, H, I_tau] = bear.tvbvar1prior(arvar, numEn, sizeB, estimLength);

            % preliminary elements for the algorithm
            % set tau as a large value
            tau = 10000;

            % compute psibar
            chibar = (chi + estimLength) / 2;

            % compute alphabar
            kappabar = estimLength + kappa;

            % step 1: determine initial values for the algorithm

            % initial value for B
            B = kron(ones(estimLength, 1), betahat);

            % initial value Omega
            omega = diag(diag(betahat * betahat'));

            % invert Omega
            invomega = diag(1 ./ diag(omega));

            % initial value for sigma
            sigma = sigmahat;

            % invert sigma
            C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
            invC = C \ speye(numEn);
            invsigma = invC * invC';

            %% Let's redo X'X and X'Y
            pre_xx = Xbar'*kron(speye(estimLength), ones(numEn, numEn)) * Xbar;   % like setting invsigma to a matrix of (numEn,numEn) ones

            pre_xy = NaN(estimLength * sizeB, numEn);
            for i = 1:estimLength
                pre_xy(1 + (i - 1) * sizeB:i * sizeB, :) = kron(ones(numEn, 1), kron(y(1 + (i - 1) * numEn:i * numEn)', ...
                    Xbar(1 + numEn * (i - 1), 1 + sizeB * (i - 1):sizeB * (i - 1) + sizeB / numEn)'));
            end

            function sample  =  sampler()

                % step 2: draw B

                invomegabar = H' * kron(I_tau, invomega) * H + ...
                    kron(speye(estimLength), kron(invsigma, ones(sizeB / numEn, sizeB / numEn))) .* pre_xx;

                % compute temporary value
                temp = sum(kron(ones(estimLength, 1), kron(invsigma, ones(sizeB / numEn, 1))) .* pre_xy, 2);

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
                Eps = reshape(eps, numEn, estimLength);

                % estimate Sbar
                Sbar = Eps * Eps' + S;

                % draw sigma
                sigma = bear.iwdraw(Sbar, kappabar);

                % invert it for next iteration
                C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % record phase
                sample.beta = mat2cell(B, repmat(sizeB, estimLength, 1));
                sample.omega = diag(omega);
                sample.sigma = sigma;
            end%

            % function A = retriever(sample, t)
            %     B = reshape(sample.beta{t}, [], numEn);
            %     A = B(1:numARows, :);
            % end%
            % 
            % this.Sampler = estimator.wrapInStabilityCheck( ...
            %     sampler=@sampler, ...
            %     retriever=@retriever, ...
            %     threshold=this.Settings.StabilityThreshold, ...
            %     numY=numEn, ...
            %     order=order, ...
            %     numPeriodsToCheck=estimLength, ...
            %     maxNumAttempts=this.Settings.MaxNumUnstableAttempts ...
            % );

            this.Sampler = @sampler;

            %]
        end%


        function createDrawers(this, meta)
            %[
            numEn = meta.NumEndogenousNames;
            numARows = numEn * meta.Order;
            numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;
            sizeB = numEn * numBRows;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            function [draw] = unconditionalDrawer(sample, startIndex, forecastHorizon)

                %draw beta, omega and sigma and F from their posterior distributions

                % draw beta
                beta = sample.beta{startIndex - 1, 1};

                % draw omega
                omega = sample.omega;

                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));

                draw.A = cell(forecastHorizon, 1);
                draw.C = cell(forecastHorizon, 1);
                draw.Sigma = cell(forecastHorizon, 1);
                Sigma = reshape(sample.sigma, numEn, numEn);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:forecastHorizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    B = reshape(beta, [], numEn);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                    draw.Sigma{jj}(:, :) = Sigma;
                end
            end

            function [draw] = conditionalDrawer(sample, startIndex, forecastHorizon )

                %draw beta, omega and sigma and F from their posterior distributions

                % draw beta
                beta = sample.beta{startIndex - 1, 1};

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
                beta = sample.beta{end};

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
                    B = reshape(beta, [], numEn);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                end

                draw.Sigma = reshape(sample.sigma, numEn, numEn);
            end%


            function draw = historyDrawer(sample)
                for jj = 1 : estimationHorizon
                    B = reshape(sample.beta{jj}, [], numEn);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                end
                draw.Sigma = repmat({reshape(sample.sigma, numEn, numEn)}, estimationHorizon, 1);
            end%


            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;

            %]
        end%

    end

end

