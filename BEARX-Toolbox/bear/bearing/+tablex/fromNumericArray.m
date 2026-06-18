

function outTable = fromNumericArray(dataArray, names, rows, options)

    arguments
        dataArray double
        names (1, :) string
        rows (:, 1)
        %
        options.VariantDim (1, 1) double
        options.HigherDims (1, :) cell = cell.empty(1, 0)
    end

    variantDim = options.VariantDim;

    if isdatetime(rows)
        tableConstructor = @(dataCell, rows, names) timetable( ...
            dataCell{:}, rowTimes=rows, variableNames=names ...
        );
    elseif ~ismissing(rows)
        tableConstructor = @(dataCell, rows, names) table( ...
            dataCell{:}, rowNames=rows, variableNames=names ...
        );
    else
        tableConstructor = @(dataCell, rows, names) table( ...
            dataCell{:}, variableNames=names ...
        );
    end

    numVariables = size(dataArray, 2);
    ndimsData = ndims(dataArray);

    dataCell = cell(1, numVariables);
    ref = repmat({':'}, 1, ndimsData);
    if variantDim==2
        permutation = 1 : ndimsData;
    else
        permutation = [1, variantDim, setdiff(3:ndimsData, variantDim), 2];
    end
    for i = 1 : numVariables
        ref{2} = i;
        dataCell{i} = permute(dataArray(ref{:}), permutation);
    end

    outTable = tableConstructor(dataCell, rows, names);
    numHigherDims = max(ndimsData-3, 0);
    outTable = tablex.addCustom(outTable, "HigherDims", cell(1, numHigherDims));

    if ~isempty(options.HigherDims)
        outTable = tablex.setHigherDims(outTable, options.HigherDims);
    end

end%

