%
% flatten  Flatten higher dimensions of time series in a table into separate
% table variables
%

function flatTable = flatten(table, options)

    arguments
        table timetable
        %
        options.Separator (1, 1) string = "___"
    end

    higherDims = tablex.getHigherDims(table);

    if isempty(higherDims)
        flatTable = table;
        return
    end

    span = tablex.span(table);
    names = textual.stringify(table.Properties.VariableNames);
    numNames = numel(names);
    flatNames = tablex.flattenNames(names, higherDims{:});

    numFlatNames = numel(flatNames);
    flatData = cell(1, numFlatNames);
    index = 1;
    for n = names
        varData = table.(n);
        numCols = size(varData, 2);
        varData = varData(:, :);
        for i = 1 : numCols : size(varData, 2)
            flatData{index} = varData(:, i+(0:numCols-1));
            index = index + 1;
        end
    end

    flatTable = tablex.fromCellArray(flatData, flatNames, span);

end%

