function [cforecast_record] = conditionalForecast(this, meta, fcastStart, fcastEnd, longYXZ, cfcondsFull, cfshocksFull, cfblocksFull)

    numEndog = meta.NumEndogenous;
    numExog = meta.NumExogenousNames+double(meta.HasIntercept);
    numLags = meta.NumLags;
    const = meta.HasIntercept;
    numPresampled = meta.NumPresampled;

    numBRows = numEndog*meta.Order + numExog;

    fcastSpan = datex.span(fcastStart, fcastEnd);
    Fperiods = length(fcastSpan);
    
    [longY, longX, ~] = longYXZ{:};

    periodsOverlap = length(datex.span(fcastStart,meta.LongEnd));

    % historical values for endogenous variables
    shortY = longY(1:end-periodsOverlap, :);

    % predicted values for exogenous variables
    shortXpred = longX(end-periodsOverlap+1:end-periodsOverlap+Fperiods, :);

    % initiate the cell recording the Gibbs sampler draws
    cforecast_record = {};

    cfconds = cfcondsFull;
    cfshocks = cfshocksFull;
    cfblocks = cfblocksFull;

    % check wether there are any conditions on unit ii
    nconds = numel(cfconds(cellfun(@(x) any(~isempty(x)),cfconds)));

    % if there are conditions
    if nconds~=0

        if const==1

            shortXpred = [ones(Fperiods,1) shortXpred];

        end

        % loop over Gibbs samplers
        for indSample = 1:numPresampled

            beta = this.Presampled{indSample}.beta;
            D = this.Presampled{indSample}.D;
            D = reshape(D, numEndog, numEndog);

            % step 2: compute regular forecasts for the data (without shocks)
            fmat=bear.forecastsim(shortY,shortXpred,beta,numEndog,numLags,numBRows,Fperiods);

            % step 3: compute IRFs and orthogonalised IRFs matrices
            [~,ortirfmat]=bear.irfsim(beta,D,numEndog,numExog,numLags,numBRows,Fperiods);

            % step 4: compute the vector of shocks generating the conditions, depending on the type of conditional forecasts selected by the user
            if CFt==1

                eta = bear.shocksim1(cfconds,Fperiods,numEndog,fmat,ortirfmat);

            elseif CFt==2

                eta = bear.shocksim2_ogr(cfconds,cfshocks,cfblocks,Fperiods,numEndog,fmat,ortirfmat);

            end 

            eta = reshape(eta, numEndog, Fperiods);
            
            % step 5: obtain the conditional forecasts
            for indPeriod = 1:Fperiods
                % compute shock contribution to forecast values
                % create a temporary vector of cumulated shock contributions
                temp = zeros(numEndog,1);

                % loop over periods up the the one currently considered
                for kk = 1:indPeriod

                    temp = temp + ortirfmat(:,:,indPeriod-kk+1)*eta(:,kk);

                end

                % compute the conditional forecast as the sum of the regular predicted component, plus shock contributions
                cdforecast(indPeriod,:) = fmat(indPeriod,:) + temp';

            end
            clear temp

            % step 6: then obtain point estimates and credibility intervals
            % loop over variables
            for indVar = 1:numEndog
                % record the conditional forecasts for variable indVar
                cforecast_record{indVar,1}(indSample,:) = cdforecast(:,indVar)';
            
            end
            % then go for next iteration
        end

    % if there are no conditions, return empty elements
    elseif nconds==0
        cforecast_record(:,:) = cell(numEndog,1);
    % cforecast_estimates(:,:,indCountry) = cell(numEndog,1);
    end
end