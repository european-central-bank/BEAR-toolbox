
% FAVAR with flat prior and two-step estimation
% FAVAR with prior = 41 in BEAR5 with lambda1>999

classdef FlatFAVARTwostep ...
    < factorTwostep.Estimator ...
    & factorTwostep.estimator.PlainFactorDrawersMixin

    properties
        Settings = factorTwostep.estimator.settings.FlatFAVARTwostep()
    end


    properties (Constant)
        Description = "Two-step FAVAR with flat prior"
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

            opt.bex = this.Settings.BlockExogenous;

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            %% FAVAR settings, maybe we can move this to a separate function

            favar = this.FAVAR;
            FY = favar.FY;

            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, p, estimLength, ~, sizeB] = ...
                bear.olsvar(FY, longX, opt.const, opt.p);

            % set initial values for B (step 2); use OLS estimates
            B = Bhat;

            LD = favar.L;

            %===============================================================================

            function sample = sampler()

                % Step 3: at iteration ii,  first draw sigma from IW,  conditional on beta from previous iteration
                % obtain first Shat,  defined in (1.6.10)
                Shat = (Y - LX * B)' * (Y - LX * B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C' * C;

                % next draw from IW(Shat, estimLength)
                sigma = bear.iwdraw(Shat, estimLength);

                % step 4: with sigma drawn,  continue iteration ii by drawing beta from a multivariate Normal,  conditional on sigma obtained in current iteration
                % first invert sigma
                C = chol(bear.nspd(sigma));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix,  Uhlig05 prior
                invomegabar = kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following,  obtain betabar
                betabar = omegabar * (kron(invsigma, LX') * Y(:));

                % draw beta from N(betabar, omegabar);
                stationary = 0;
                while stationary  ==  0
                    % draw from N(betabar, omegabar);
                    beta = betabar + chol(bear.nspd(omegabar), 'lower') * mvnrnd(zeros(sizeB, 1), eye(sizeB))';
                    [stationary] = bear.checkstable(beta, numEn, p, size(B, 1)); %switches stationary to 0,  if the draw is not stationary
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

