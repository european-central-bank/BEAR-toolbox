
function checkEndogenousAndShocksInTable(tbl, meta)

    compareLists = @isequal;

    tableEndogenousHeadings = textual.stringify(tbl.Properties.RowNames);
    if ~compareLists(meta.SeparableEndogenousNames, tableEndogenousHeadings)
        error("Row names in the restriction table must match endogenous names in the model.");
    end

    tableShockHeadings = textual.stringify(tbl.Properties.VariableNames);
    if ~compareLists(meta.SeparableShockNames, tableShockHeadings)
        error("Column names in the restriction table must match shock names in the model.");
    end

end%

