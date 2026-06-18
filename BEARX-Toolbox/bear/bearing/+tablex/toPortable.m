
function outTable = toPortable(table, compress, options)

    arguments
        table timetable
        compress function_handle
        options.separator (1, 1) string = "___"
    end

    table = tablex.apply(table, compress);

    try
        higherDims = tablex.getHigherDims(table);
    catch
        higherDims = {};
    end

    if isempty(higherDims)
        outTable = table;
        return
    end

    time = table.Properties.RowTimes;
    variableNames = table.Properties.VariableNames;
    thirdDim = higherDims{1};

    allNames = names.crossList(options.separator, variableNames, thirdDim);
    allValues = cell(1, numel(allNames));
    counter = 0;
    for i = 1 : numel(variableNames)
        x = table{:, variableNames(i)};
        for j = 1 : numel(thirdDim)
            counter = counter + 1;
            allValues{counter} = x(:, :, j);
        end
    end

    outTable = timetable(time, allValues{:}, variableNames=allNames);

end%

