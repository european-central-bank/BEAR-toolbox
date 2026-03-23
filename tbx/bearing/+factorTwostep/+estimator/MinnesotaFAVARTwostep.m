
% FAVAR with Minnesota prior and two-step estimation
% FAVAR version of prior =11 12 and 13 BEAR5

classdef MinnesotaFAVARTwostep ...
    < factorTwostep.Estimator ...
    & factorTwostep.estimator.PlainFactorDrawersMixin


    properties
        Settings = factorTwostep.estimator.settings.MinnesotaFAVARTwostep()
    end


    properties (Constant)
        Description = "Two-step FAVAR with Minnesota prior"
        Category = "Two-step factor-augmented estimators"
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


            sigmaAdapter = struct();
            sigmaAdapter.diag = 12;
            sigmaAdapter.ar = 11;
            sigmaAdapter.full = 13;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;
            opt.bex = this.Settings.BlockExogenous;

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            %% FAVAR settings, maybe we can move this to a separate function

            favar = this.FAVAR;
            FY = favar.FY;

            [Bhat, ~, ~, LX, ~, ~, y, EPS, ~, numEn, numEx, p, estimLength, numBRows, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);
            sigmahat = (1 / estimLength) * (EPS' * EPS);

            [arvar] = bear.arloop(FY, opt.const, p, numEn);

            [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, numEn, numEx, p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);

            % obtain posterior distribution parameters
            [betabar, omegabar] = bear.mpost(beta0, omega0, sigma, LX, y, sizeB, numEn);

            LD = favar.L;
            B = Bhat;

            %===============================================================================

            function sample = sampler()

                % draw beta from N(betabar,omegabar);
                stationary = 0;
                while stationary==0
                    beta = betabar + chol(bear.nspd(omegabar), 'lower')*mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1) ); %switches stationary to 0, if the draw is not stationary
                end

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

