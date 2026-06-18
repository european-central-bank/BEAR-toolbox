
% FAVAR with Indenpendent Normal-Wishart prior and one-step estimation
% FAVAR with prior 31 and 32 in BEAR5

classdef IndNormalWishartFAVAROnestep ...
    < factorOnestep.Estimator

    properties
        Settings = factorOnestep.estimator.settings.IndNormalWishartFAVAROnestep()
    end

    properties (Constant)
        Description = "One-step FAVAR with independent Normal-Wishart prior"
        Category = "One-step factor-augmented estimators"
        HasCrossUnits = false
        CanBeIdentified = true
        OneStepFactors = true
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

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

            opt.bex = this.Settings.BlockExogenous;

            sigmaAdapter = struct();
            sigmaAdapter.eye = 32;
            sigmaAdapter.ar = 31;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            opt.L0 = this.Settings.LoadingVariance;
            opt.a0 = this.Settings.SigmaShape;
            opt.b0 = this.Settings.SigmaScale;

            %% FAVAR settings, maybe we can move this to a separate function

            favar = this.FAVAR;
            FY = favar.FY;

            [Bhat, ~, ~, LX, ~, Y, ~, EPS, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = bear.olsvar(FY, longX, ...
                opt.const, opt.p);

            B_ss = [Bhat' ; eye(numEn * (p - 1)) zeros(numEn * (p - 1), numEn)];
            sigma_ss = [(1 / estimLength) * (EPS' * EPS) zeros(numEn, numEn * (p - 1)); zeros(numEn * (p - 1), numEn * p)];

            XZ0mean = zeros(numEn * p, 1);
            XZ0var = opt.L0*eye(numEn * p);
            L0 = opt.L0*eye(numEn);

            XY = favar.XY;
            LD = favar.L;
            Sigma = bear.nspd(favar.Sigma);
            favar_X = favar.X;
            nfactorvar = favar.nfactorvar;
            numpc = favar.numpc;
            indexnM = favar.indexnM;
            %===============================================================================

            function sample = sampler()

                % Sample latent factors using Carter and Kohn (1994)
                FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, LD, Sigma, B_ss, sigma_ss, indexnM);

                % demean generated factors
                FY = bear.favar_demean(FY);

                % Sample autoregressive coefficients B
                [B, ~, ~, LX, ~, Y, y] = bear.olsvar(FY, longX, opt.const, p);

                [arvar] = bear.arloop(FY, opt.const, p, numEn);

                % set prior values, new with every iteration for onestep only
                [beta0, omega0, S0, alpha0] = bear.inwprior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                    opt.lambda5, numEn, numEx, p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);

                % invert omega0, as it will be used repeatedly
                invomega0 = diag(1 ./ diag(omega0));
                % set the value of alphahat, defined in (1.5.16)
                alphahat = estimLength + alpha0;


                % Step 3: at iteration ii,  first draw sigma from IW,  conditional on beta from previous iteration
                % obtain first Shat,  defined in (1.5.15)
                Shat = (Y - LX * B)' * (Y - LX * B) + S0;

                % Correct potential asymmetries due to rounding errors from Matlab
                Shat = bear.nspd(Shat);

                % next draw from IW(Shat, alphahat)
                sigma = bear.iwdraw(Shat, alphahat);
                sigma_ss(1:numEn, 1:numEn) = sigma;

                % step 4: with sigma drawn,  continue iteration ii by drawing beta from a multivariate Normal,  conditional on sigma obtained in current iteration
                % first invert sigma
                C = bear.trns(chol(bear.nspd(sigma), 'Lower'));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following,  obtain betabar
                betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * y);

                % draw beta from N(betabar, omegabar);
                stationary = 0;
                while stationary ==0
                    % draw from N(betabar, omegabar);
                    beta = betabar + chol(bear.nspd(omegabar), 'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn,  p, size(B, 1)); %switches stationary to 0,  if the draw is not stationary
                end

                B = reshape(beta, size(B));
                B_ss(1:numEn, :) = B';
                % Sample Sigma and L
                [Sigma, LD] = bear.favar_SigmaL(Sigma, LD, nfactorvar, numpc, true, numEn, favar_X,...
                    FY, opt.a0, opt.b0, estimLength, p, L0);

                % update matrix B with each draw

                sample.beta = beta;
                sample.sigma = sigma;
                sample.FY = FY;
                sample.LD = LD;
                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

