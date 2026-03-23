
function cfshocks = createCfshocks(meta, condTable, forecastSpan)

    endoNames = meta.EndogenousNames;
    numEn = numel(meta.EndogenousNames);

    fcastLength = numel(forecastSpan);
    cfshocks = cell(fcastLength, numEn);
    dict = cell2struct(num2cell(1:numel(meta.ShockNames)), meta.ShockNames, 2);
    
    for nn = 1 : numEn
        tmp = condTable(:, endoNames(nn));
        nonEmptyRows = ~cellfun(@isempty, tmp.Variables);
        resctrictedTable = tmp(nonEmptyRows, :);
        [~, ix] = ismember(resctrictedTable.Time, forecastSpan);
        ix = ix(ix > 0);
        if ~isempty(ix)
            tmpcell = resctrictedTable.Variables;
            for kk = 1:numel(tmpcell)
                cfshocks{ix(kk), nn} = arrayfun(@(x) dict.(x), tmpcell{kk});
            end
        end
    end

end