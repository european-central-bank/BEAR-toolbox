%{
% # `tablex.apply`
%
% ==Apply a function across columns of a table==
%
% ## Syntax
%
%     outTable = tablex.apply(inTable, func)
%
% ## Input arguments
%
% * `inTable` - Input table.
%
% * `func` - Function handle or a string that evaluates to a function handle.
%
% ## Output arguments
%
% * `outTable` - Output table.
%
% ## Notes
%
% * The function `func` must accept a single input argument and return a single
% output argument.
%
% * The function `func` can be a function handle or a string that evaluates to a
% function handle. If the input is a string, it must be one of the following
% predefined strings:
%
%     - `"first"` - Return the first element in each column.
%     - `"last"` - Return the last element in each column.
%     - `"max"` - Return the maximum across all columns.
%     - `"min"` - Return the minimum across all columns.
%     - `"sum"` - Return the sum of all columns.
%     - `"mean"` - Return the mean across all columns.
%     - `"median"` - Return the median across all columns.
%     - `"std"` - Return the standard deviation across all columns.
%     - `"var"` - Return the variance across all columns.
%
%}

function outTable = apply(inTable, func, varargin)

    arguments
        inTable timetable
        func {validateFunc}
    end
    arguments (Repeating)
        varargin
    end

    if isstring(func) || ischar(func)
        func = resolveFunctionString(func);
    end

    names = string(inTable.Properties.VariableNames);
    periods = tablex.span(inTable);
    data = tablex.retrieveDataAsCellArray(inTable, names, periods, variant=":");

    for i = 1 : numel(data)
        data{i} = func(data{i});
    end

    outTable = tablex.fromCellArray(data, names, periods);

    try
        higherDims = tablex.getHigherDims(inTable);
        outTable = tablex.setHigherDims(outTable, higherDims);
    end

end%


function validateFunc(func)
    if ~isa(func, "function_handle") && ~isstring(func) && ~ischar(func)
        error("The input argument 'func' must be a function handle or a string");
    end
end%


function func = resolveFunctionString(func)
    PREDEFINED_FUNCTIONS = struct( ...
        "first", @(x) column(x, 1), ...
        "last", @(x) column(x, size(x, 2)), ...
        "max", @(x) max(x, [], 2), ...
        "min", @(x) min(x, [], 2), ...
        "sum", @(x) sum(x, 2), ...
        "mean", @(x) mean(x, 2), ...
        "median", @(x) median(x, 2), ...
        "std", @(x) std(x, 0, 2), ...
        "var", @(x) var(x, 0, 2) ...
    );
    func = PREDEFINED_FUNCTIONS.(func);
end%


function y = column(x, i)
    ref = repmat({':'}, 1, ndims(x)-2);
    y = x(:, i, ref{:});
end%

