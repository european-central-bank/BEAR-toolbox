
function [outArray, periods] = retrieveDataAsCellArray(inTable, names, periods, options)

    arguments
        inTable timetable
        names (1, :) string
        periods (1, :) datetime

        options.Variant (1, :) = 1
        options.Dims (1, :) cell = cell.empty(1, 0)
        options.Shift (1, 1) double = 0
    end

    periods = tablex.resolvePeriods(inTable, periods, shift=options.Shift);

    if isstring(options.Variant)
        options.Variant = char(options.Variant);
    end

    numTablePeriods = height(inTable);
    numNames = numel(names);
    numPeriods = numel(periods);

    tableStartPeriod = tablex.startPeriod(inTable);
    fh = datex.Backend.getFrequencyHandlerFromDatetime(tableStartPeriod);
    startSerial = fh.serialFromDatetime(tableStartPeriod);
    requestedSerials = fh.serialFromDatetime(periods);
    rows = requestedSerials - startSerial + 1;

    % Replace out-of-span rows with NaN
    pointerToNaN = numTablePeriods + 1;
    rows(rows <= 0 | rows > numTablePeriods) = pointerToNaN;

    outArray = cell(1, numNames);
    customDims = 3 + (0 : numel(options.Dims)-1);
    for i = 1 : numNames
        name = names(i);
        data = inTable.(name);

        ndimsData = ndims(data);
        ref = repmat({':'}, 1, ndimsData);
        ref{2} = options.Variant;
        ref(customDims) = options.Dims;
        data = data(ref{:});

        % Create a NaN row to be used for out-of-span periods
        data(end+1, :) = NaN;

        ref = repmat({':'}, 1, ndimsData);
        ref{1} = rows;
        outArray{i} = data(ref{:});
    end

end%

