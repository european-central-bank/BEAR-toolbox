
% FAVAR with Minnesota prior and one-step estimation
% FAVAR version of prior =11 12 and 13 BEAR5

classdef MinnesotaFAVAROnestep ...
    < factorOnestep.Estimator

    properties
        Settings = factorOnestep.estimator.settings.MinnesotaFAVAROnestep()
    end


    properties (Constant)
        Description = "One-step FAVAR with Minnesota prior"
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

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

            opt.L0 = this.Settings.LoadingVariance;
            opt.a0 = this.Settings.SigmaShape;
            opt.b0 = this.Settings.SigmaScale;

            sigmaAdapter = struct();
            sigmaAdapter.diag = 12;
            sigmaAdapter.ar = 11;
            sigmaAdapter.full = 13;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            favar = this.FAVAR;

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;
            opt.bex = this.Settings.BlockExogenous;

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            %% FAVAR settings, maybe we can move this to a separate function

            FY = favar.FY;

            [Bhat, ~, ~, LX, ~, ~, ~, EPS, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            B_ss = [Bhat' ; eye(numEn * (p - 1)) zeros(numEn * (p - 1), numEn)];
            sigma_ss = [(1 / estimLength) * (EPS' * EPS) zeros(numEn, numEn * (p - 1)); zeros(numEn * (p - 1), numEn * p)];

            XZ0mean = zeros(numEn * p,1);
            XZ0var = opt.L0*eye(numEn * p);
            XY = favar.XY;
            LD = favar.L;
            Sigma = bear.nspd(favar.Sigma);
            favar_X = favar.X;
            nfactorvar = favar.nfactorvar;
            numpc = favar.numpc;
            indexnM = favar.indexnM;

            L0 = opt.L0*eye(numEn);
            sigmahat = (1 / estimLength) * (EPS' * EPS);
            %===============================================================================

            function sample = sampler()

                % Sample latent factors using Carter and Kohn (1994)
                FY = bear.favar_kfgibbsnv(XY, XZ0mean, XZ0var, LD, Sigma, B_ss, sigma_ss, indexnM);

                % demean generated factors
                FY = bear.favar_demean(FY);

                % Sample autoregressive coefficients B,in the twostep procedure FY is static, and we want to use updated B
                [~, ~, ~, LX, ~, ~, y] = bear.olsvar(FY, longX, opt.const, p);
                [arvar] = bear.arloop(FY, opt.const, p, numEn);

                % set prior values
                [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, ...
                    opt.lambda4, opt.lambda5, numEn, numEx, p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);

                % obtain posterior distribution parameters
                [betabar,omegabar] = bear.mpost(beta0, omega0, sigma, LX, y, sizeB, numEn);

                sigma_ss(1:numEn,1:numEn) = sigma;

                % draw beta from N(betabar,omegabar);
                stationary=0;
                while stationary==0
                    beta = betabar + chol(bear.nspd(omegabar), 'lower')*mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, numBRows ); %switches stationary to 0, if the draw is not stationary
                end

                % update matrix B with each draw

                B = reshape(beta, numBRows, []);
                B_ss(1:numEn,:) = B';
                % Sample Sigma and L
                [Sigma, LD] = bear.favar_SigmaL(Sigma, LD, nfactorvar, numpc, true, numEn, favar_X, FY, ...
                    opt.a0, opt.b0, estimLength, p, L0);

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

