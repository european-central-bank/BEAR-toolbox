
function tbl = replaceMissing(tbl, options)
% Replace missing values with NaN (for numeric columns) or "" (for string
% columns).

    arguments
        tbl table
        options.TimeColumn (1, 1) string = "Time"
    end

    columnNames = tablex.getColumnNames(tbl);
    columnNames = setdiff(columnNames, options.TimeColumn, "stable");

    for n = columnNames
        data = tbl{:, n};
        if isstring(data)
            data(ismissing(data)) = "";
        elseif isnumeric(data)
            data(ismissing(data)) = NaN;
        end
        tbl{:, n} = data;
    end

end%
