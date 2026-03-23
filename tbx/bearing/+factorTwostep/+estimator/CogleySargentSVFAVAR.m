
% FAVAR version of Standard Stochastic Volatility model
% FAVAR with stvol = 1 in BEAR5

classdef CogleySargentSVFAVAR ...
    < factorTwostep.Estimator

    properties
        Settings = factorTwostep.estimator.settings.CogleySargentSVFAVAR()
    end


    properties (Constant)
        Description = "Two-step FAVAR with Cogley-Sargent stochastic volatility"
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

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;
            priorexo = this.Settings.Exogenous;

            opt.gamma = this.Settings.HeteroskedasticityAutoRegression;
            opt.alpha0 = this.Settings.HeteroskedasticityShape;
            opt.delta0 = this.Settings.HeteroskedasticityScale;

            opt.bex = this.Settings.BlockExogenous;
            opt.ar = this.Settings.Autoregression;

            favar = this.FAVAR;
            FY = favar.FY;

            [~, betahat, sigmahat, LX, ~, Y, ~, ~, ~, numY, numEx, p, estimLength, numBRows, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            [arvar]  =  bear.arloop(FY, opt.const, p, numY);

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            %create matrices
            [yt, ~, Xbart]  =  bear.stvoltmat(Y, LX, numY, estimLength); %create TV matrices
            [beta0, omega0, G, I_o, omega, f0, upsilon0] = bear.stvol1prior(opt.ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, numY, numEx, p, estimLength, numBRows, sizeB, opt.bex, blockexo, opt.gamma, priorexo);

            % preliminary elements for the algorithm
            % compute the product G'*I_gamma*G (to speed up computations of deltabar)
            GIG = G' * I_o * G;

            % compute alphabar
            alphabar = estimLength + opt.alpha0;

            % step 1: determine initial values for the algorithm

            % initial value for beta
            beta = betahat;

            % initial value for f_2,...,f_n
            % obtain the triangular factorisation of sigmahat
            [Fhat, Lambdahat] = bear.triangf(sigmahat);

            % obtain the inverse of Fhat
            [invFhat] = bear.invltod(Fhat,numY);

            % create the cell storing the different vectors of invF
            Finv = cell(numY, 1);

            % store the vectors
            for ii = 2:numY
                Finv{ii, 1} = invFhat(ii, 1:ii - 1);
            end

            % initial values for L_1,...,L_n
            L = zeros(estimLength, numY);

            % initial values for phi_1,...,phi_n
            phi = ones(1, numY);



            % step 2: determine the sbar values and Lambda
            sbar = diag(Lambdahat);
            Lambda = sparse(diag(sbar));


            % step 3: recover the series of initial values for lambda_1,...,lambda_T and sigma_1,...,sigma_T
            lambda_t = repmat(diag(sbar), [1 1 estimLength]);
            sigma_t = repmat(sigmahat, [1 1 estimLength]);


            LD = favar.L;

            %===============================================================================


            function sample   =   sampler()

                summ1  =  zeros(sizeB, sizeB);
                summ2  =  zeros(sizeB, 1);

                % run the summation
                for zz  =  1:estimLength
                    prodt = Xbart{zz, 1}' / sigma_t(:, :, zz);
                    summ1 = summ1 + prodt * Xbart{zz, 1};
                    summ2 = summ2 + prodt * yt(:, :, zz);
                end

                % then obtain the inverse of omega0
                invomega0 = diag(1./ diag(omega0));
                % obtain the inverse of omegabar
                invomegabar = summ1 + invomega0;

                % recover omegabar
                C = chol(bear.nspd(invomegabar), 'Lower')';
                invC = C\speye(sizeB);
                omegabar = invC * invC';

                % recover betabar
                betabar = omegabar * (summ2 + invomega0 * beta0);

                % finally,  draw beta from its posterior
                beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(sizeB, 1);

                % step 5: draw the series f_2, ..., f_n from their conditional posteriors
                % recover first the residuals
                for zz = 1:estimLength
                    epst(:, :, zz) = yt(:, :, zz) - Xbart{zz, 1} * beta;
                end

                % then draw the vectors in turn
                for zz = 2:numY
                    % first compute the summations required for upsilonbar and fbar
                    summ1 = zeros(zz - 1, zz - 1);
                    summ2 = zeros(zz - 1, 1);

                    % run the summation
                    for kk = 1:estimLength
                        prodt = epst(1:zz - 1, 1, kk) * exp( - L(kk, zz));
                        summ1 = summ1 + prodt * epst(1:zz - 1, 1, kk)';
                        summ2 = summ2 + prodt * epst(zz, 1, kk)';
                    end

                    summ1 = (1 / sbar(zz, 1)) * summ1;
                    summ2 = ( - 1 / sbar(zz, 1)) * summ2;

                    % then obtain the inverse of upsilon0
                    invupsilon0 = diag(1 ./ diag(upsilon0{zz, 1}));

                    % obtain upsilonbar
                    invupsilonbar = summ1 + invupsilon0;
                    C = chol(bear.nspd(invupsilonbar));
                    invC = C\speye(zz - 1);
                    upsilonbar = full(invC * invC');

                    % recover fbar
                    fbar = upsilonbar * (summ2 + invupsilon0 * f0{zz, 1});

                    % finally draw f_i^( - 1)
                    Finv{zz, 1} = fbar + chol(bear.nspd(upsilonbar), 'lower') * randn(zz - 1, 1);
                end

                % recover the inverse of F
                invF = eye(numY);
                for zz = 2:numY
                    invF(zz, 1:zz - 1) = Finv{zz, 1};
                end

                % eventually recover F
                F = bear.invltod(invF, numY);

                % then update sigma
                sigma = F * Lambda * F';

                % step 6: draw the series phi_1, ..., phi_n from their conditional posteriors
                % draw the parameters in turn
                for zz = 1:numY
                    % estimate deltabar
                    deltabar = L(:, zz)' * GIG * L(:, zz) + opt.delta0;
                    % draw the value phi_i
                    phi(1, zz) = bear.igrandn(alphabar / 2, deltabar / 2);
                end


                % step 7: draw the series lambda_i, t from their conditional posteriors,  i = 1, ..., numY and t = 1, ..., estimLength
                % consider variables in turn
                for zz = 1:numY

                    % consider periods in turn
                    for kk = 1:estimLength
                        % a candidate value will be drawn from N(lambdabar, phibar)
                        % the definitions of lambdabar and phibar varies with the period,  thus define them first
                        % if the period is the first period
                        if kk == 1
                            lambdabar = (opt.gamma * L(2, zz)) / (1 / omega + opt.gamma^2);
                            phibar = phi(1, zz) / (1 / omega + opt.gamma^2);

                            % if the period is the final period
                        elseif kk == estimLength
                            lambdabar = opt.gamma * L(estimLength - 1, zz);
                            phibar = phi(1, zz);

                            % if the period is any period in - between
                        else
                            lambdabar = (opt.gamma / (1 + opt.gamma^2)) * (L(kk - 1, zz) + L(kk + 1, zz));
                            phibar = phi(1, zz) / (1 + opt.gamma^2);
                        end

                        % now draw the candidate
                        cand = lambdabar + phibar^0.5 * randn;

                        % compute the acceptance probability
                        prob = bear.mhprob2(zz, cand, L(kk, zz), sbar(zz, 1), epst(:, 1, kk), Finv{zz, 1});

                        % draw a uniform random number
                        draw = rand;

                        % keep the candidate if the draw value is lower than the prob
                        if draw <= prob
                            L(kk, zz) = cand;
                            % if not,  just keep the former value
                        end
                    end
                end
                % then recover the series of matrices lambda_t and sigma_t
                for zz=1:estimLength
                    lambda_t(:, :, zz) = diag(sbar) .* diag(exp(L(zz, :)));
                    sigma_t(:, :, zz) = F * lambda_t(:, :, zz) * F';
                end

                sample.beta = beta;
                sample.F = F;
                sample.L = mat2cell(L, ones(estimLength, 1), numY);
                sample.phi = phi;
                sample.sigmaAvg = sigma(:);
                sample.sbar = sbar;

                sample.FY = FY;
                sample.LD = LD;

                for zz = 1:estimLength
                    sample.lambda_t{zz, 1} = lambda_t(:, :, zz);
                    sample.sigma_t{zz, 1} = sigma_t(:, :, zz);
                end

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
            estimationHorizon = numel(meta.ShortSpan);
            identificationHorizon = meta.IdentificationHorizon;

            %IRF periods
            % IRFperiods = meta.IRFperiods;

            %other settings
            gamma = this.Settings.HeteroskedasticityAutoRegression;


            function draw = unconditionalDrawer(sample, startingIndex, forecastHorizon )

                beta = sample.beta;
                % reshape it to obtain B
                B = reshape(beta, [], numY);

                % draw F from its posterior distribution
                F = sparse(sample.F(:,:));

                % step 4: draw phi and gamma from their posteriors
                phi = sample.phi';
                lambda =  sample.L{startingIndex - 1,:}';

                sbar = sample.sbar;

                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);

                draw.A = repmat({A}, forecastHorizon, 1);
                draw.C = repmat({C}, forecastHorizon, 1);
                draw.Sigma = cell(forecastHorizon, 1);

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods estimLength+1 to estimLength+h
                for jj = 1:forecastHorizon

                    for kk = 1:numY
                        lambda(kk, 1) = gamma * lambda(kk, 1) + phi(kk, 1)^0.5 * randn;
                    end

                    % obtain Lambda_t
                    Lambda = sparse(diag(sbar .* exp(lambda)));

                    % recover sigma_t and draw the residuals
                    draw.Sigma{jj, 1}(:, :) = full(F * Lambda * F');
                end
            end

            function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )

                beta = sample.beta;
                draw.beta = repmat({beta}, forecastHorizon, 1);

            end%

            function draw = identificationDrawer(sample)

                horizon = identificationHorizon;
                beta = sample.beta;
                % reshape it to obtain B
                B = reshape(beta, [], numY);

                A = B(1:numARows, :);
                C = B(numARows + 1:end, :);

                draw.A = repmat({A}, horizon, 1);
                draw.C = repmat({C}, horizon, 1);
                draw.Sigma = reshape(sample.sigmaAvg, numY, numY);
                % draw.LD = reshape(sample.LD, [], numY);

            end

            function draw = historyDrawer(sample)

                beta = sample.beta;

                % reshape it to obtain B
                B = reshape(beta, [], numY);
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
