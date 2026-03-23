
% Normal-Wishart
% prior =21 and 22 in BEAR5

classdef NormalWishart ...
    < base.Estimator ...
    & base.estimator.PlainDrawersMixin

    properties
        Settings = base.estimator.settings.NormalWishart()
    end


    properties (Constant)
        Description = "VAR with Normal-Wishart prior"
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

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;

        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, numEn, numEx);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.eye = 22;
            sigmaAdapter.ar = 21;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, ~, ~, numBRows, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

            estimLength = size(Y, 1);

            % LX = add dummies
            % Y = add dummies

            priorexo = this.Settings.Exogenous;

            ar = this.Settings.Autoregression;

            %variance from univariate OLS for priors
            arvar = bear.arloop(longY, opt.const, opt.p, numEn);

            %setting up prior
            [B0, ~, phi0, S0, alpha0] = bear.nwprior( ...
                ar, arvar, opt.lambda1, opt.lambda3, opt.lambda4, ...
                numEn, numEx, opt.p, numBRows, sizeB, opt.prior, priorexo ...
            );

            % obtain posterior distribution parameters
            [Bbar, ~, phibar, Sbar, alphabar, alphatilde] = bear.nwpost(B0, phi0, S0, alpha0, LX, Y, numEn, estimLength, numBRows);

            function sample = sampler_()
                B = bear.matrixtdraw(Bbar, Sbar, phibar, alphatilde, numBRows, numEn);
                sigma = bear.iwdraw(Sbar, alphabar);
                sample.beta = B(:);
                sample.sigma = sigma;
                this.SampleCounter = this.SampleCounter + 1;
            end%
            %
            this.Sampler = @sampler_;
            %]
        end%
    end

end

