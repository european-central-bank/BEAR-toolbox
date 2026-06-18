
classdef Threshold ...
    < threshold.Estimator

    properties
        Settings = threshold.estimator.settings.Threshold()
    end


    properties (Constant)
        Description = "VAR with threshold-based regime switching"
        HasCrossUnits = false
        CanBeIdentified = false
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

            opt.varThreshold = this.Settings.VarThreshold;
            opt.maxDelay = this.Settings.MaxDelay;

            opt.thresholdPropStd = this.Settings.ThresholdPropStd;

            opt.const = meta.HasIntercept;
            opt.p = meta.Order;

            if opt.maxDelay > opt.p
               opt.maxDelay = opt.p;
            end

            [~, ~, ~, LX, ~, Y, ~, ~, ~, numEn, ~, ~, estimLength, ~, ~] = ...
                bear.olsvar(longY, longX, opt.const, opt.p);

            numARows = numEn * opt.p;

            for r = 1:2
                sigma(:, :, r) = eye(numEn);
            end

            %Find the threshold variable
            thInd = meta.ThresholdNameIndex;
            thVar = Y(:, thInd);
            meanThreshold = mean(thVar);

            % Extract lagged values of threshold variable
            thresholdvar = LX(:, thInd:numEn:thInd + (opt.maxDelay - 1)*numEn);

            delay = 1;
            th = meanThreshold;


            %===============================================================================
            function sample = sampler()

                [B, sigma, sample] = thresholdUtils.drawBSigma(sigma, th, ...
                    delay, thresholdvar, Y, LX, dummiesYLX);

                th = thresholdUtils.drawThreshold(B, sigma, th, delay,...
                    thresholdvar, meanThreshold, opt.varThreshold, Y, LX,...
                    opt.thresholdPropStd);

                delay = thresholdUtils.drawDelay(opt.maxDelay, B, sigma, th, thresholdvar,...
                    meanThreshold, opt.varThreshold, Y, LX);

                sample.beta = cell(estimLength, 1);
                sample.sigma_t = cell(estimLength, 1);
                for r = 1:2
                    regimeInd = thresholdUtils.getRegimeInd(th, delay, ...
                        thresholdvar, r);
                    sample.beta(regimeInd,1)= {sample.("B" + string(r))(:)};
                    sample.sigma_t(regimeInd,1) = {sample.("sigma" + string(r))(:)};
                end
                sample.delay = delay;
                sample.threshold = th;
            end%
            %===============================================================================

            % function A = retriever(sample, t)
            %     B = reshape(sample.beta{t}, [], numEn);
            %     A = B(1:numARows, :);
            % end%

            % this.Sampler = estimator.wrapInStabilityCheck( ...
            %     sampler=@sampler, ...
            %     retriever=@retriever, ...
            %     threshold=this.Settings.StabilityThreshold, ...
            %     numY=numEn, ...
            %     order=order, ...
            %     numPeriodsToCheck=estimLength, ...
            %     maxNumAttempts=this.Settings.MaxNumUnstableAttempts ...
            % );

            this.Sampler = @sampler;

        end%



        function createDrawers(this, meta)
            %[

            %sizes
            numEn = meta.NumEndogenousNames;
            numARows = numEn * meta.Order;
            % numBRows = numARows + meta.NumExogenousNames + meta.HasIntercept;
            % sizeB = numEn * numBRows;
            estimationHorizon = numel(meta.ShortSpan);
            %identificationHorizon = meta.IdentificationHorizon;

            function draw = unconditionalDrawer(sample, startingIndex, forecastHorizon )
                %
                B1 = sample.B1;
                B2 = sample.B2;

                sigma1 = sample.sigma1;
                sigma2 = sample.sigma2;

                draw.A1 = cell(forecastHorizon, 1);
                draw.A2 = cell(forecastHorizon, 1);
                draw.C1 = cell(forecastHorizon, 1);
                draw.C2 = cell(forecastHorizon, 1);
                draw.Sigma1 = cell(forecastHorizon, 1);
                draw.Sigma2 = cell(forecastHorizon, 1);

                draw.threshold = sample.threshold;
                draw.delay = sample.delay;

                % then generate forecasts recursively
                % for each iteration ii, repeat the process for periods T+1 to T+h
                for jj = 1:forecastHorizon
                    draw.A1{jj, 1}(:, :) = B1(1:numARows, :);
                    draw.C1{jj, 1}(:, :) = B1(numARows + 1:end, :);

                    draw.A2{jj, 1}(:, :) = B2(1:numARows, :);
                    draw.C2{jj, 1}(:, :) = B2(numARows + 1:end, :);

                    draw.Sigma1{jj, 1}(:, :) = sigma1;
                    draw.Sigma2{jj, 1}(:, :) = sigma2;
                end
                %
            end%
            %

            % function draw = conditionalDrawer(sample, startingIndex, forecastHorizon )
            %     %
            %     %draw beta, omega
            %     %
            %     beta = sample.beta{startingIndex - 1, 1};
            %     omega = sample.omega;
            %     %
            %     % create a choleski of omega, the variance matrix for the law of motion
            %     cholomega = sparse(diag(omega));
            %     %
            %     draw.beta = cell(forecastHorizon, 1);
            %
            %     for jj = 1:forecastHorizon
            %         % update beta
            %         beta = beta + cholomega*randn(sizeB, 1);
            %         draw.beta{jj, 1}(:) = beta;
            %     end
            %     %
            % end%


            % function [draw] = identificationDrawer(sample)
            %     %
            %     horizon = identificationHorizon;
            %     %
            %     %draw beta, omega from their posterior distribution
            %     % draw beta
            %     beta = sample.beta{end};
            %     %
            %     omega = sample.omega;
            %     %
            %     % create a choleski of omega, the variance matrix for the law of motion
            %     cholomega = sparse(diag(omega));
            %     %
            %     draw.A = cell(horizon, 1);
            %     draw.C = cell(horizon, 1);
            %     %
            %     % then generate forecasts recursively
            %     % for each iteration ii, repeat the process for periods T+1 to T+h
            %     for jj = 1:horizon
            %         % update beta
            %         beta = beta + cholomega*randn(sizeB, 1);
            %         B = reshape(beta, [], numEn);
            %         draw.A{jj}(:, :) = B(1:numARows, :);
            %         draw.C{jj}(:, :) = B(numARows + 1:end, :);
            %     end
            %     %
            %     draw.Sigma = reshape(sample.sigmaAvg, numEn, numEn);
            %     %
            % end%


            function draw = historyDrawer(sample)
                %
                draw.A = cell(estimationHorizon, 1);
                draw.C = cell(estimationHorizon, 1);
                draw.Sigma = cell(estimationHorizon, 1);
                %
                for jj = 1:estimationHorizon
                    B = reshape(sample.beta{jj}, [], numEn);
                    draw.A{jj}(:, :) = B(1:numARows, :);
                    draw.C{jj}(:, :) = B(numARows + 1:end, :);
                    draw.Sigma{jj}(:, :) = sample.sigma_t{jj}(:, :);
                end
                %
            end%

            this.UnconditionalDrawer = @unconditionalDrawer;
            % this.ConditionalDrawer = @conditionalDrawer;
            % this.IdentificationDrawer = @identificationDrawer;
            this.HistoryDrawer = @historyDrawer;

            %]
        end%
    end

end

