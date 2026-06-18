
function [fcastY, fcastE] = forecastMA(D, A, initY, fcastHorizon, options)

    order = options.order;
    cfconds = options.cfconds;
    cfshocks = options.cfshocks;
    cfblocks = options.cfblocks;

    numEndog = size(initY, 2);

    % check wether there are any conditions and whether it's conditioned by all shocks or only one
    flagCond = any(any(cellfun(@(x) ~isempty(x), cfconds)));
    isSelective = ~isempty(cfshocks);

    fcastY = NaN(fcastHorizon, numEndog);

  
    % if there are conditions
    if flagCond
        % step 2: compute regular forecasts for the data (without shocks)
        fmat = bear.ogrTVEmaforecastsim(initY, A, order, numEndog, fcastHorizon);
        
        [~,ortirfmat] = bear.mairfsim(A, D, order, numEndog, fcastHorizon);

        if ~isSelective

            fcastE = bear.ogrshocksim1(cfconds, fcastHorizon, numEndog, fmat, ortirfmat);

        else

            fcastE = bear.shocksim2(cfconds, cfshocks, cfblocks, fcastHorizon,...
                numEndog, eye(numEndog), fmat, ortirfmat);

        end

        fcastE = reshape(fcastE, numEndog, fcastHorizon);

        % step 5: obtain the conditional forecasts
        for indPeriod = 1:fcastHorizon

            % compute shock contribution to forecast values
            % create a temporary vector of cumulated shock contributions
            temp = zeros(numEndog, 1);

            % loop over periods up the the one currently considered
            for kk = 1:indPeriod
                temp = temp + ortirfmat(:, :, indPeriod - kk + 1)*fcastE(:, kk);
            end

            % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
            fcastY(indPeriod, :) = fmat(indPeriod, :) + temp';
        end
        % clear temp

        % then go for next iteration
    end
    
    fcastE = transpose(fcastE);

end%

