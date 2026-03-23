
% VAR with Minnesota prior
% prior =11 12 and 13 in BEAR5

classdef Minnesota ...
    < base.Estimator ...
    & base.estimator.PlainDrawersMixin

    properties
        Settings = base.estimator.settings.Minnesota()
    end


    properties (Constant)
        Description = "VAR with Minnesota prior"
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
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;
        %     if isscalar(opt.lambda4)
        %         opt.lambda4 = repmat(opt.lambda4, numEn, numEx);
        %     end

            sigmaAdapter = struct();
            sigmaAdapter.diag = 12;
            sigmaAdapter.ar = 11;
            sigmaAdapter.full = 13;
            opt.prior = sigmaAdapter.(lower(this.Settings.Sigma));

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [~, ~, sigmahat, LX, ~, Y, ~, ~, ~, numEn, numEx, p, ~, numBRows, sizeB] = bear.olsvar(longY, longX, opt.const, opt.p);

            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);


            priorexo = this.Settings.Exogenous;
            ar = this.Settings.Autoregression;
            opt.bex = this.Settings.BlockExogenous;

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            %variance from univariate OLS for priors
            arvar = bear.arloop(longY, opt.const, opt.p, numEn);

            %setting up prior
            [beta0, omega0, sigma] = bear.mprior(ar, arvar, sigmahat, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, ...
                opt.lambda5, numEn, numEx, p, numBRows, sizeB, opt.prior, opt.bex, blockexo, priorexo);

            % obtain posterior distribution parameters
            [betabar, omegabar] = bear.mpost(beta0, omega0, sigma, LX, Y(:), sizeB, numEn);
            %===============================================================================

            function sample = sampler()
                beta = betabar + chol(bear.nspd(omegabar), 'lower') * randn(sizeB, 1);
                sample.beta = beta;
                sample.sigma = sigma;
                this.SampleCounter = this.SampleCounter + 1;
            end%

            % numY = meta.NumEndogenousNames;
            % order = meta.Order;
            % numL = numY * order;
            % 
            % function A = retriever(sample, t)
            %     B = reshape(sample.beta, [], numY);
            %     A = B(1:numL, :);
            % end%

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

