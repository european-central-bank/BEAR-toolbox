
function outTable = reconcileTimetable(inTable, options)

    arguments
        inTable timetable
        options.Frequency (1, 1) double = Frequency.INTEGER
        options.Trim (1, 1) logical = true
    end

    if height(inTable) == 0
        return
    end

    % Reconcile dates
    if isequaln(options.Frequency, NaN)
        freq = datex.frequency(timeColumn(1));
        if isequaln(freq, NaN)
            error("Cannot determine time frequency of the time column");
        end
    else
        freq = options.Frequency;
    end

    fh = datex.Backend.getFrequencyHandlerFromFrequency(freq);

    dates = inTable.Time;
    dates = fh.datetimeFromDatetime(dates);

    uniqueDates = unique(dates);
    if numel(uniqueDates) ~= numel(dates)
        error("Duplicate dates found in timetable")
    end

    periods = fh.datetimeFromDatetime(dates);
    serials = fh.serialFromDatetime(periods);
    minSerial = min(serials);
    maxSerial = max(serials);
    numPeriods = maxSerial - minSerial + 1;
    newSerials = reshape(minSerial : maxSerial, [], 1);
    newPeriods = fh.datetimeFromSerial(newSerials);
    positions = serials - minSerial + 1;

    variableNames = string(inTable.Properties.VariableNames);
    numVariables = numel(variableNames);
    storeData = cell.empty(1, 0);
    for name = string(inTable.Properties.VariableNames)
        variable = inTable.(name);
        numColumns = size(variable, 2);
        array = initializeArray__(variable, numPeriods, numColumns);
        array(positions, :) = variable;
        storeData{end+1} = array;
    end

    outTable = timetable( ...
        storeData{:} ...
        , rowTimes=newPeriods ...
        , variableNames=variableNames ...
    );

    if options.Trim
        outTable = tablex.trim(outTable);
    end

end%


function array = initializeArray__(variable, numPeriods, numColumns)
    %[
    if isnumeric(variable)
        array = nan(numPeriods, numColumns);
    elseif islogical(variable)
        array = nan(numPeriods, numColumns);
    elseif isstring(variable)
        array = strings(numPeriods, numColumns);
    else
        error("Cannot initialize array of class " + class(variable));
    end
    %]
end%

