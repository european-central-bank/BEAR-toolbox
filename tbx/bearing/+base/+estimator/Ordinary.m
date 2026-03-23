
% Ordinary least squares

classdef Ordinary ...
    < base.Estimator ...
    & base.estimator.PlainDrawersMixin

    properties
        Settings = base.estimator.settings.Ordinary()
    end


    properties (Constant)
        Description = "Ordinary least squares"
        Category = "Plain estimators"
        HasCrossUnits = false
        CanBeIdentified = true
        CanHaveDummies = true
    end


    methods
        function initializeSampler(this, meta, longYX, dummiesYLX)
            %[

            arguments
                this
                meta
                longYX (1, 2) cell
                dummiesYLX (1, 2) cell
            end

            [longY, longX] = longYX{:};


            opt.const = meta.HasIntercept;
            opt.p = meta.Order;
            fixedSigma = this.Settings.FixedSigma;
            fixedBeta = this.Settings.FixedBeta;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, ~, numBRows, ~] = bear.olsvar(longY, longX, opt.const, opt.p);
            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

            estimLength = size(Y, 1);

            %setting up prior
            [Bcap, ~, Scap, alphacap, phicap, alphatop] = bear.dopost(LX, Y, estimLength, numBRows, numEn);

            % Stabilized lower Cholesky factor of Scap
            cholScap = chol(bear.nspd(Scap), "lower");
            cholPhicap = chol(bear.nspd(phicap), "lower");

            %===============================================================================

            function sample = sampler()

                B = bear.matrixtdraw2(Bcap, cholScap, cholPhicap, alphatop, numBRows, numEn, fixedBeta, fixedSigma);

                % then draw sigma from an inverse Wishart distribution with scale matrix Scap and degrees of freedom alphacap (step 3)
                sigma = bear.iwdraw2(cholScap, alphacap, fixedSigma);

                sample.beta = B(:);
                sample.sigma = sigma;

                this.SampleCounter = this.SampleCounter + 1;

            end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

