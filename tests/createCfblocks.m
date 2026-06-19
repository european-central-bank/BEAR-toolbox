function cfblocks = createCfblocks(cfconds, cfshocks)

    [Fperiods, numEn] = size(cfconds);
    cfblocks = zeros(Fperiods, numEn);
    
    % Loop over each row
    for period = 1:Fperiods
        uniqueVectors = {};
    
        for variable = 1:numEn
            if ~isempty(cfconds{period, variable}) && ~isempty(cfshocks{period, variable})
                currentVector = cfshocks{period, variable};
                block = find(cellfun(@(x) isequal(x, currentVector), uniqueVectors), 1);
    
                if isempty(block)
                    uniqueVectors{end+1} = currentVector;
                    block = numel(uniqueVectors);
                end
    
                cfblocks(period, variable) = block;
            end
        end
    end

end