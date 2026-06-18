
function conditionsCF = createConditionsCF(meta, planTbx, dataTbx, fcastSpan)

    endogenousNames = meta.PseudoEndogenousNames;
    dataArray = dataTbx{fcastSpan, endogenousNames};
    conditionsCF = num2cell(dataArray);

    if isempty(planTbx)
        return
    end

    planArray = planTbx{fcastSpan, endogenousNames}; 
    inxConditionsInPlan = ~cellfun(@isempty, planArray, uniformOutput=true);
    inxMissing = isnan(dataArray) & inxConditionsInPlan;
    if ~any(inxMissing(:))
        return
    end

    missing = string.empty(1, 0);
    [rows, columns] = find(inxMissing);
    for i = 1 : numel(rows)
        missingPeriod = fcastSpan(rows(i));
        missingNames = endogenousNames(columns(i));
        missing = [missing, sprintf("%s[%s]", missingNames, missingPeriod)];
    end
    error("Conditioning data missing for " + join(missing, ", "));

%     [longY, ~, ~] = longYXZ{:};
%     order = meta.Order;
% 
%     shortY = longY(order + 1:end, :);
%     endoNames = meta.EndogenousNames;
%     numEn = numel(meta.EndogenousNames);
% 
%     fcastLength = numel(forecastSpan);
%     conditionsCF = cell(fcastLength, numEn);
% 
%     for nn = 1 : numEn
%         tmp = dataTbx(:, endoNames(nn));
%         nonEmptyRows = ~cellfun(@isempty, tmp.Variables);
%         nonEmptyTimes = tmp.Time(nonEmptyRows);
%         [~, ix] = ismember(nonEmptyTimes, forecastSpan);
%         ix = ix(ix>0);
%         if ~isempty(ix)
%             for i = 1:numel(ix)
%                 conditionsCF{ix(i), nn} = shortY(ix(i), nn);
%             end
%         end
%     end

end%
