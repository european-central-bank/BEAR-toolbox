
function testStrings = testStringsFromIneqRestrictTable(tbl, model)
    arguments
        tbl (:, :) table
        model (1, 1)
    end
    %
    tablex.validateSignRestrictions(tbl, model=model);
    %
    endogenousNames = string(tbl.Properties.RowNames);
    shockNames = string(tbl.Properties.VariableNames);
    numEndogenousNames = numel(endogenousNames);
    numShockNames = numel(shockNames);
    %
    tbl = tablex.homogenizeTextual(tbl);
    testStrings = string.empty(0, 1);
    data = tbl{:, :};
    for i = 1 : numEndogenousNames
        for j = 1 : numShockNames
            [expression, periods, numPeriods] = extractExpressionAndPeriods__(data(i, j));
            if isequal(expression, "") && isequal(periods, [])
                continue
            end
            test = sprintf( ...
                "$SHKRESP(%s,'%s','%s')%s", ...
                periods, ...
                endogenousNames(i), ...
                shockNames(j), ...
                expression ...
            );
            if numPeriods > 1
                test = "all(" + test + ")";
            end
            testStrings(end+1, 1) = test;
        end
    end
end%


function [expression, periods, numPeriods] = extractExpressionAndPeriods__(dataPoint)
    %[
    if ismissing(dataPoint) || isequal(strip(dataPoint), "")
        expression = "";
        periods = [];
        numPeriods = 0;
        return
    end
    %
    expression = strip(extractBefore(dataPoint, "["));
    expression = erase(expression, " ");
    periods = extractBetween(dataPoint, "[", "]", boundaries="inclusive");
    periods = eval(periods);
    if isempty(periods) || ~isnumeric(periods) || any(periods < 0) || any(periods ~= round(periods))
        error("This sign restriction table entry has invalid periods: %s", dataPoint);
    end
    periods = sort(unique(reshape(periods, 1, [])));
    numPeriods = numel(periods);
    %
    periods = string(periods);
    if numPeriods > 1
        periods = "[" + join(periods, ",") + "]";
    end
    %]
end%


