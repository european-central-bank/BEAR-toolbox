
function ct = new(options)

    arguments
        options.RowNames (1, :) string = missing
        options.ColumnNames (1, :) string = missing
        options.Periods (1, :) = missing
        options.InitValue (1, 1) = NaN
    end

    rowNames = options.RowNames;
    columnNames = options.ColumnNames;
    periods = options.Periods;
    initValue = options.InitValue;

    if ismissing(rowNames)
        numRows = 1;
    else
        rowNames = string(rowNames);
        numRows = numel(rowNames);
    end

    if ismissing(columnNames)
        error("Column names must be specified");
    else
        columnNames = string(columnNames);
        numColumns = numel(columnNames);
    end

    if ismissing(periods)
        numPeriods = 1;
    else
        numPeriods = numel(periods);
    end

    placeholder = repmat(initValue, numRows, numPeriods);
    placeholders = repmat({placeholder}, 1, numColumns);

    if ~ismissing(rowNames)
        ct = table(placeholders{:}, rowNames=rowNames, variableNames=columnNames);
    else
        ct = table(placeholders{:}, variableNames=columnNames);
    end

    if ~ismissing(periods)
        ct = tablex.addCustom(ct, Periods=periods);
    end

end%

