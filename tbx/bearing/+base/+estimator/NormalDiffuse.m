
% VAR with Normal-Diffuse prior
% prior = 41 in BEAR5

classdef NormalDiffuse ...
    < base.Estimator ...
    & base.estimator.PlainDrawersMixin

    properties
        Settings = base.estimator.settings.NormalDiffuse()
    end


    properties (Constant)
        Description = "VAR with Normal-Diffuse prior"
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

            priorexo = this.Settings.Exogenous;

            opt.lambda1 = this.Settings.Lambda1;
            opt.lambda2 = this.Settings.Lambda2;
            opt.lambda3 = this.Settings.Lambda3;
            opt.lambda4 = this.Settings.Lambda4;
            opt.lambda5 = this.Settings.Lambda5;

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            [Bhat, ~, ~, LX, ~, Y, ~, ~, ~, numEn, numEx, p, ~, numBRows, sizeB] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            [Y, LX] = dummies.addDummiesToData(Y, LX, dummiesYLX);

            estimLength = size(Y, 1);

            opt.bex = this.Settings.BlockExogenous;
            ar = this.Settings.Autoregression;

            arvar =  bear.arloop(longY, opt.const, p, numEn);

            blockexo  =  [];
            if  opt.bex == 1
                [blockexo] = bear.loadbex(endo, pref);
            end

            %setting up prior
            [beta0, omega0] = bear.ndprior(ar, arvar, opt.lambda1, opt.lambda2, opt.lambda3, opt.lambda4, opt.lambda5, ...
                numEn, numEx, opt.p, numBRows, sizeB, opt.bex, blockexo, priorexo);

            invomega0 = diag(1./diag(omega0));
            B = Bhat;

            %===============================================================================

            function sample = sampler()
                % draw sigma from IW, conditional on beta from previous iteration
                % obtain first Shat, defined in (1.6.10)
                Shat = (Y - LX * B)' * (Y - LX * B);
                % Correct potential asymmetries due to rounding errors from Matlab
                C = chol(bear.nspd(Shat));
                Shat = C' * C;

                % next draw from IW(Shat,estimLength)
                sigma = bear.iwdraw(Shat, estimLength);

                % Continue iteration by drawing beta from a multivariate Normal, conditional on sigma obtained in current iteration
                % first invert sigma
                C = chol(bear.nspd(sigma));
                invC = C \ speye(numEn);
                invsigma = invC * invC';

                % then obtain the omegabar matrix
                invomegabar = invomega0 + kron(invsigma, LX' * LX);
                C = chol(bear.nspd(invomegabar));
                invC = C \ speye(sizeB);
                omegabar = invC * invC';

                % following, obtain betabar
                betabar = omegabar * (invomega0 * beta0 + kron(invsigma, LX') * Y(:));

                % draw from N(betabar,omegabar);
                beta = betabar + chol(bear.nspd(omegabar),'lower') * mvnrnd(zeros(sizeB,1),eye(sizeB))';

                % update matrix B with each draw
                B = reshape(beta,size(B));

                sample.beta = beta;
                sample.sigma = sigma;
                this.SampleCounter = this.SampleCounter + 1;
            end

            this.Sampler = @sampler;

            %===============================================================================

            %]
        end%
    end

end

