
function tbl = convert(tbl, convertTo, options)

    arguments
        tbl table
        convertTo
        options.TimeColumn (1, 1) string = "Time"
    end

    if isempty(convertTo) || isequal(convertTo, "")
        return
    end

    columnNames = tablex.getColumnNames(tbl);
    columnNames = setdiff(columnNames, options.TimeColumn, "stable");

    tbl = convertvars(tbl, columnNames, convertTo);

end%

