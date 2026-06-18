
function blocksCF = createBlocksCF(conditionsCF, shocksCF)

    if isempty(shocksCF)
        blocksCF = [];
        return
    end

    [numPeriods, numEndogenousNames] = size(conditionsCF);
    blocksCF = zeros(numPeriods, numEndogenousNames);

    for period = 1 : numPeriods
        uniqueVectors = {};
        for variable = 1 : numEndogenousNames
            if ~isempty(conditionsCF{period, variable}) && ~isempty(shocksCF{period, variable})
                currentVector = shocksCF{period, variable};
                block = find(cellfun(@(x) isequal(x, currentVector), uniqueVectors), 1);

                if isempty(block)
                    uniqueVectors{end+1} = currentVector;
                    block = numel(uniqueVectors);
                end

                blocksCF(period, variable) = block;
            end
        end
    end

end%

