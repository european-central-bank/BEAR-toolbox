
function [fcastY, fcastE] = forecast(D, beta_iter, initY, shortX, fcastHorizon, options)

    order = options.order;
    hasIntercept = options.hasIntercept;
    cfconds = options.cfconds;
    cfshocks = options.cfshocks;
    cfblocks = options.cfblocks;

    numEndog = size(initY, 2);
    numExog = size(shortX, 2) + hasIntercept;

    numBRows = numEndog*order + numExog;

    X = shortX;
    X = system.addInterceptWhenNeeded(X, hasIntercept);

    Y = transpose(flipud(initY));
    ybarT = Y(:);

    % check wether there are any conditions and whether it's conditioned by all shocks or only one
    flagCond = any(any(cellfun(@(x) ~isempty(x), cfconds)));
    isSelective = ~isempty(cfshocks);

    fcastY = NaN(fcastHorizon, numEndog);


    % if there are conditions
    if flagCond
        % step 2: compute regular forecasts for the data (without shocks)
        [fmat, ortirfcell] = bear.tvcfsim1(beta_iter, D, ybarT, X, fcastHorizon, numEndog, numExog, order, numBRows);

        if ~isSelective

            fcastE = bear.shocksim5(cfconds, fcastHorizon, numEndog, fmat, ortirfcell);

        else

            fcastE = bear.shocksim6(cfconds, cfshocks, cfblocks, fcastHorizon, numEndog, eye(numEndog), fmat, ortirfcell);

        end

        if ~isempty(fcastE)
            fcastE = reshape(fcastE, numEndog, fcastHorizon);
        else
            fcastE = zeros(numEndog, fcastHorizon);
        end

        % step 5: obtain the conditional forecasts
        for indPeriod = 1:fcastHorizon

            % compute shock contribution to forecast values
            % create a temporary vector of cumulated shock contributions
            temp = zeros(numEndog,1);

            % loop over periods up the the one currently considered
            for kk = 1:indPeriod
                temp = temp + ortirfcell{indPeriod - kk + 1, indPeriod}(:, :)*fcastE(:, kk);
            end

            % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
            fcastY(indPeriod, :) = fmat(indPeriod, :) + temp';
        end
        % clear temp

        % then go for next iteration
    end

    fcastE = transpose(fcastE);

end%

