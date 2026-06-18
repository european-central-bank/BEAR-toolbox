
function outArray = retrieveData(inTable, names, periods, options)

    arguments
        inTable timetable
        names (1, :) string
        periods (1, :) datetime

        options.Variant (1, :) = 1
        options.Dims (1, :) cell = cell.empty(1, 0)
        options.Shift (1, 1) double = 0

        options.Permute (:, :) double = [1, 3, 2]
    end

    [cellArray, periods] = tablex.retrieveDataAsCellArray( ...
        inTable, names, periods, ...
        variant=options.Variant, ...
        dims=options.Dims, ...
        shift=options.Shift ...
    );

    if ~isempty(options.Permute)
        for i = 1 : numel(cellArray)
            cellArray{i} = permute(cellArray{i}, options.Permute);
        end
    end

    if ~isempty(cellArray) && ~isempty(cellArray{1})
        sizeDummy = size(cellArray{1});
        sizeDummy(2) = 0;
        dummy = zeros(sizeDummy);
    else
        numPeriods = numel(periods);
        dummy = zeros(numPeriods, 0);
    end

    outArray = [dummy, cellArray{:}];

end%

