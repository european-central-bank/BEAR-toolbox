
function out = validateInstantZeros(tbl, model)

    arguments
        tbl (:, :) table
        options.Model = []
    end


    % Validate table data

    validateData__(tbl);


    % Validate row and column names

    if ~isempty(options.Model)
        meta = model.getMeta();
        validateNames__(tbl, meta);
    end


    out = true;

end%


function validateData__(tbl)
    %[
    data = tbl{:, :};
    %
    if ~isnumeric(data)
        error("Entries in the exact zeros table must be numeric zeros or NaNs.");
    end
    %
    inxValid = isnan(data) | data ~= 0;
    if ~all(inxValid(:))
        error("Entries in the exact zeros table must be numeric zeros or NaNs.");
    end
    %]
end%


function validateNames__(tbl, meta))
    %[
    separableEndogenousNames = meta.SeparableEndogenousNames;
    separableShockNames = meta.SeparableShockNames;
    %
    rowNames = tablex.getRowNames(tbl);
    columnNames = tablex.getColumnNames(tbl);
    %
    if ~isequal(rowNames, separableEndogenousNames)
        error("The row names of the sign restrictions table must match the model's separable endogenous names.");
    end
    %
    if ~isequal(columnNames, separableShockNames)
        error("The column names of the sign restrictions table must match the model's separable shock names.");
    end
    %]
end%

