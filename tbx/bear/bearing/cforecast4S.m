function [cdforecast, eta] = cforecast4S(D, beta_iter, initY, shortX, forecastHorizon, options)

    % [longY, longX, ~] = longYXZ{:};

    order = options.order;
    hasIntercept = options.hasIntercept;
    cfconds = options.cfconds;
    cfshocks = options.cfshocks;
    cfblocks = options.cfblocks;

    numEndog = size(initY, 2);
    numExog = size(shortX, 2) + hasIntercept;

    numBRows = numEndog*order + numExog;

    % X = longX(order + 1:end, :);
    X = shortX;
    X = system.addInterceptWhenNeeded(X, hasIntercept);

    Y = transpose(flipud(initY));
    ybarT = Y(:);

    % check wether there are any conditions and whether it's conditioned by all shocks or only one
    flagCond = any(any(cellfun(@(x) ~isempty(x), cfconds)));
    flagSimPlan = any(any(cellfun(@(x) ~isempty(x), cfshocks)));

    cdforecast = NaN(forecastHorizon, numEndog);


    % if there are conditions
    if flagCond
        % step 2: compute regular forecasts for the data (without shocks)
        [fmat, ortirfcell] = bear.tvcfsim1(beta_iter, D, ybarT, X, forecastHorizon, numEndog, numExog, order, numBRows);

        if ~flagSimPlan

            eta = bear.shocksim5(cfconds, forecastHorizon, numEndog, fmat, ortirfcell);

        else

            eta = bear.shocksim6(cfconds, cfshocks, cfblocks, forecastHorizon, numEndog, eye(numEndog), fmat, ortirfcell);

        end

        eta = reshape(eta, numEndog, forecastHorizon);

        % step 5: obtain the conditional forecasts
        for indPeriod = 1:forecastHorizon

            % compute shock contribution to forecast values
            % create a temporary vector of cumulated shock contributions
            temp = zeros(numEndog,1);

            % loop over periods up the the one currently considered
            for kk = 1:indPeriod
                temp = temp + ortirfcell{indPeriod - kk + 1, indPeriod}(:, :)*eta(:, kk);
            end

            % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
            cdforecast(indPeriod, :) = fmat(indPeriod, :) + temp';
        end
        % clear temp

        % then go for next iteration
    end

    eta = transpose(eta);

end%

