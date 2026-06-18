
function out = validateSignRestrictions(tbl, options)

    arguments
        tbl (:, :) table
        options.Model = []
    end


    % Validate table data

    validateData__(tbl);


    % Validate row and column names if a model is provided

    if ~isempty(options.Model)
        meta = options.Model.getMeta();
        validateNames__(tbl, meta);
    end


    out = true;

end%


function validateData__(tbl)
    %[
    tbl = tablex.homogenizeTextual(tbl);
    data = tbl{:, :};
    data = data(:);
    data(data == "") = [];
    %
    inxValid = startsWith(data, "<") | startsWith(data, ">");
    if ~all(inxValid)
        error("Non-empty sign restriction table entries must start with '<' or '>'.");
    end
    %
    inxValid = (contains(data, "[") & contains(data, "]"));
    if ~all(inxValid)
        error("Non-empty sign restriction table entries must contain periods enclosed between '[' and ']'.");
    end
    %]
end%


function validateNames__(tbl, meta)
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


