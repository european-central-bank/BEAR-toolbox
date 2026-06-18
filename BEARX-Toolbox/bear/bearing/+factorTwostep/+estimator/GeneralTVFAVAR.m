
% FAVAR verison of model with time-varying parameters and stochastic volatility,
% FAVAR with tvbvar = 2 in BEAR5

classdef GeneralTVFAVAR ...
    < factorTwostep.Estimator

    properties
        Settings = factorTwostep.estimator.settings.GeneralTVFAVAR()
    end

    properties (Constant)
        Description = "Two-step FAVAR with time-varying parameters and stochastic volatility"
        Category = "Time-varying factor-augmented estimators"
        HasCrossUnits = false
        CanBeIdentified = true
        OneStepFactors = false
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


            opt.gamma = this.Settings.HeteroskedasticityAutoRegression;
            opt.alpha0 = this.Settings.HeteroskedasticityShape;
            opt.delta0 = this.Settings.HeteroskedasticityScale;

            favar = this.FAVAR;
            FY = favar.FY;

            [~, betahat, sigmahat, LX, ~, Y, ~, ~, ~, numY, ~, p, estimLength, ~, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            [arvar] = bear.arloop(FY, opt.const, p, numY);

            [yt, y, ~, Xbart, Xbar] = bear.tvbvarmat(Y, LX, numY, sizeB, estimLength); %create TV matrices
            [chi, psi, ~, ~, H, I_tau, G, I_om, f0, upsilon0] = bear.tvbvar2prior(arvar, numY, sizeB, estimLength, opt.gamma);

            GIG = G' * I_om * G;

            % set tau as a large value
            tau = 10000;

            % set omega as a large value
            om = 5;

            % compute psibar
            chibar = (chi + estimLength) / 2;

            % compute alphabar
            alphabar = estimLength + opt.alpha0;

            % initial value Omega
            omega = diag(diag(betahat * betahat'));

            % invert Omega
            invomega = diag(1 ./ diag(omega));

            % initial value for f_2, ..., f_n
            % obtain the triangular factorisation of sigmahat
            [Fhat,  Lambdahat] = bear.triangf(sigmahat);

            % obtain the inverse of Fhat
            [invFhat] = bear.invltod(Fhat, numY);

            % create the cell storing the different vectors of invF
            Finv = cell(numY, 1);

            % store the vectors
            for ii = 2:numY
                Finv{ii, 1} = invFhat(ii, 1:ii - 1);
            end

            % initial values for L_1, ..., L_n
            L = zeros(estimLength, numY);

            % initial values for phi_1, ..., phi_n
            phi = ones(1, numY);

            % initiate invsigmabar
            invsigmabar = sparse(kron(eye(estimLength), inv(sigmahat)));

            % step 2: determine the sbar values and Lambda
            sbar = diag(Lambdahat);
            Lambda = sparse(diag(sbar));

            % step 3: recover the series of initial values for lambda_1, ..., lambda_T and sigma_1, ..., sigma_T
            lambda_t  =  repmat(diag(sbar), 1, 1, estimLength);
            sigma_t   =  repmat(sigmahat, 1, 1, estimLength);
            epst = zeros(numY , 1 , estimLength);


            LD = favar.L;
            %===============================================================================
            function sample  =  sampler()

                % step 4: draw B
                invomegabar = H' * kron(I_tau, invomega) * H + Xbar' * invsigmabar * Xbar;

                % compute the choleski of invomegabar
                C = chol(bear.nspds(invomegabar), 'Lower');

                % compute temporary value
                temp = Xbar' * invsigmabar * y;

                % smoothing phase: solve by back substitution
                temp1 = C \ temp;

                % smoothing phase: solve by forward substitution
                Bbar = C' \ temp1;

                % simulation phase:
                B = Bbar + C' \ randn(sizeB * estimLength, 1);

                % reshape
                Beta = reshape(B, sizeB, estimLength);

                % step 5: draw omega from its posterior
                % compute the summ
                summ = (1 / tau) * Beta(:, 1) * Beta(:, 1)';

                for zz = 2:estimLength
                    summ = summ + (Beta(:, zz) - Beta(:, zz - 1)) * (Beta(:, zz) - Beta(:, zz - 1))';
                end

                summ = diag(summ);

                % obtain Qbar
                psibar = summ + psi;

                % draw omega
                omega = diag(arrayfun(@bear.igrandn, kron(ones(sizeB, 1), chibar), psibar));

                % invert it for next iteration
                invomega = diag(1 ./ diag(omega));

                % step 6: draw the series f_2, ..., f_n from their conditional posteriors
                % recover first the residuals
                for jj = 1:estimLength
                    epst(:, :, jj) = yt(:, :, jj) - Xbart{jj, 1} * Beta(:, jj);
                end

                % then draw the vectors in turn
                for jj = 2:numY
                    % first compute the summations required for upsilonbar and fbar
                    summ1 = zeros(jj - 1, jj - 1);
                    summ2 = zeros(jj - 1, 1);

                    % run the summation
                    for kk = 1:estimLength
                        prodt = epst(1:jj - 1, 1, kk) * exp( - L(kk, jj));
                        summ1 = summ1 + prodt * epst(1:jj - 1, 1, kk)';
                        summ2 = summ2 + prodt * epst(jj, 1, kk)';
                    end

                    summ1 = (1 / sbar(jj, 1)) * summ1;
                    summ2 = ( - 1 / sbar(jj, 1)) * summ2;

                    % then obtain the inverse of upsilon0
                    invupsilon0 = diag(1 ./ diag(upsilon0{jj, 1}));

                    % obtain upsilonbar
                    invupsilonbar = summ1 + invupsilon0;
                    C = chol(bear.nspd(invupsilonbar));
                    invC = C \ speye(jj - 1);
                    upsilonbar = full(invC * invC');

                    % recover fbar
                    fbar = upsilonbar * (summ2 + invupsilon0 * f0{jj, 1});

                    % finally draw f_i^( - 1)
                    Finv{jj, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(jj - 1, 1);
                end

                % recover the inverse of F
                invF = eye(numY);

                for jj = 2:numY
                    invF(jj, 1:jj - 1) = Finv{jj, 1};
                end

                % eventually recover F
                F = bear.invltod(invF, numY);

                % then update sigma
                sigma = F * Lambda * F';

                % step 7: draw the series phi_1, ..., phi_n from their conditional posteriors
                % draw the parameters in turn
                for jj = 1:numY
                    % estimate deltabar
                    deltabar = L(:, jj)' * GIG * L(:, jj) + opt.delta0;

                    % draw the value phi_i
                    phi(1, jj) = bear.igrandn(alphabar / 2, deltabar / 2);
                end

                % step 8: draw the series lambda_i, t from their conditional posteriors,  i = 1, ..., numY and t = 1, ..., estimLength
                % consider variables in turn
                for jj = 1:numY
                    % consider periods in turn
                    for kk = 1:estimLength
                        % a candidate value will be drawn from N(lambdabar, phibar)
                        % the definitions of lambdabar and phibar varies with the period,  thus define them first
                        % if the period is the first period

                        if kk == 1
                            lambdabar = (opt.gamma * L(2, jj)) / (1 / om + opt.gamma^2);
                            phibar = phi(1, jj) / (1 / om + opt.gamma^2);
                            % if the period is the final period
                        elseif kk == estimLength
                            lambdabar = opt.gamma * L(estimLength - 1, jj);
                            phibar = phi(1, jj);
                            % if the period is any period in - between
                        else
                            lambdabar = (opt.gamma / (1 + opt.gamma^2)) * (L(kk - 1, jj) + L(kk + 1, jj));
                            phibar = phi(1, jj) / (1 + opt.gamma^2);
                        end

                        % now draw the candidate
                        cand = lambdabar + phibar^0.5 * randn;

                        % compute the acceptance probability
                        prob = bear.mhprob2(jj, cand, L(kk, jj), sbar(jj, 1), epst(:, 1, kk), Finv{jj, 1});

                        % draw a uniform random number
                        draw = rand;

                        % keep the candidate if the draw value is lower than the prob
                        if draw <= prob
                            L(kk, jj) = cand;
                            % if not,  just keep the former value
                        end
                    end
                end

                % then recover the series of matrices lambda_t and sigma_t
                for jj = 1:estimLength
                    lambda_t(:, :, jj) = diag(sbar) .* diag(exp(L(jj, :)));
                    sigma_t(:, :, jj) = F * lambda_t(:, :, jj) * F';
                end

                % record the results
                sample.beta = mat2cell(B, repmat(sizeB, estimLength, 1));
                sample.omega = diag(omega);
                sample.F = F;
                sample.sbar = sbar;
                sample.L = mat2cell(L, ones(estimLength, 1), numY);
                sample.phi = phi;
                sample.sigmaAvg = sigma(:);

                for jj = 1:estimLength
                    sample.lambda_t{jj, 1}(:, :) = lambda_t(:, :, jj);
                    sample.sigma_t{jj, 1}(:, :) = sigma_t(:, :, jj);
                end
                sample.FY = FY;
                sample.LD = LD;

            end

            this.Sampler = @sampler;

            %]
        end%


        function createDrawers(this, meta)
            %[

            %sizes
            numEn = meta.NumEndogenousNames;
            numPC = meta.NumFactorNames;
            numY = numEn + numPC;
            numARows = numY * meta.Order;
            numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;
            sizeB = numY * numBRows;
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            gamma = this.Settings.HeteroskedasticityAutoRegression;


            function draw = unconditionalDrawer(sample, startingIndex, forecastHorizon )
                %
                %draw beta, omega and sigma and F from their posterior distributions
                %
                beta = sample.beta{startingIndex - 1, 1};
                omega = sample.omega;
                %
                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));
                %
                % draw F from its posterior distribution
                F = sparse(sample.F);
                %
                % step 4: draw phi from its posterior
                phi = sample.phi';
                %
                % also, compute the pre-sample value of lambda, the stochastic volatility process
                lambda = sample.L{startingIndex - 1}';
                %
                sbar = sample.sbar;
                %
                draw.A = cell(forecastHorizon, 1);
                draw.C = cell(forecastHorizon, 1);
                draw.Sigma = cell(forecastHorizon, 1);
                %
                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:forecastHorizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    B = reshape(beta, [], numY);
                    draw.A{jj, 1}(:, :) = B(1:numARows, :);
                    draw.C{jj, 1}(:, :) = B(numARows + 1:end, :);
                    %
                    % update lambda_t and obtain Lambda_t
                    % loop over variables
                    for kk = 1:numY
                        lambda(kk, 1) = gamma * lambda(kk, 1) + phi(kk, 1)^0.5 * randn;
                    end
                    %
                    % obtain Lambda_t
                    Lambda = sparse(diag(sbar .* exp(lambda)));
                    %
                    % recover sigma_t and draw the residuals
                    draw.Sigma{jj, 1}(:, :) = full(F * Lambda * F');
                end
                %
            end%


            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )
                %
                %draw beta, omega
                %
                beta = sample.beta{startingIndex - 1, 1};
                omega = sample.omega;
                %
                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));
                %
                draw.beta = cell(forecastHorizon, 1);

                for jj = 1:forecastHorizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    draw.beta{jj, 1}(:) = beta;
                end
                %
            end%


            function [draw] = identificationDrawer(sample)
                %
                horizon = identificationHorizon;
                %
                %draw beta, omega from their posterior distribution
                % draw beta
                beta = sample.beta{end, 1};
                %
                omega = sample.omega;
                %
                % create a choleski of omega, the variance matrix for the law of motion
                cholomega = sparse(diag(omega));
                %
                draw.A = cell(horizon, 1);
                draw.C = cell(horizon, 1);
                %
                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:horizon
                    % update beta
                    beta = beta + cholomega*randn(sizeB, 1);
                    B = reshape(beta, [], numY);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                end
                %
                draw.Sigma = reshape(sample.sigmaAvg, numY, numY);
                % draw.LD = reshape(sample.LD, [], numY);                %
            end%


            function draw = historyDrawer(sample)
                %
                draw.A = cell(estimationHorizon, 1);
                draw.C = cell(estimationHorizon, 1);
                draw.Sigma = cell(estimationHorizon, 1);
                %
                for jj = 1:estimationHorizon
                    B = reshape(sample.beta{jj}, [], numY);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                    draw.Sigma{jj}(:, :) = sample.sigma_t{jj}(:, :);
                end
                %
            end%

            this.UnconditionalDrawer = @unconditionalDrawer;
            this.ConditionalDrawer = @conditionalDrawer;
            this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;

            %]
        end%

    end

end

