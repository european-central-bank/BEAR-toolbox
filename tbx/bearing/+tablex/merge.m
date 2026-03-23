
function outTable = merge(firstTable, secondTable, options)

    arguments
        firstTable timetable
        secondTable timetable
        options.strategy (1, 1) string {mustBeMember(options.strategy, ["overlay", "replace", "discard", "error"])} = "overlay"
    end

    if height(secondTable) == 0
        outTable = firstTable;
        return
    end

    if height(firstTable) == 0
        outTable = secondTable;
        return
    end

    firstFreq = tablex.frequency(firstTable);
    secondFreq = tablex.frequency(secondTable);
    if firstFreq ~= secondFreq
        error("Cannot merge timetables with different time frequencies: %s and %s.", firstFreq, secondFreq);
    end

    firstNames = tablex.names(firstTable);
    secondNames = tablex.names(secondTable);
    mergedNames = unique([firstNames, secondNames], "stable");

    [mergedSpan, secondSpanIndex] = resolveSpans_(firstTable, secondTable);
    numPeriods = numel(mergedSpan);
    errorNames = string.empty(1, 0);

    function out = overlay_(firstVariable, secondVariable, ~)
        numFirstVariants = size(firstVariable, 2);
        numSecondVariants = size(secondVariable, 2);
        if numFirstVariants == 1 && numSecondVariants > 1
            firstVariable = repmat(firstVariable, 1, numSecondVariants);
        elseif numFirstVariants > 1 && numSecondVariants == 1
            secondVariable = repmat(secondVariable, 1, numFirstVariants);
        end
        out = firstVariable;
        out(secondSpanIndex, :) = secondVariable(secondSpanIndex, :);
    end%

    function out = replace_(firstVariable, secondVariable, ~)
        out = secondVariable;
    end%

    function out = discard_(firstVariable, secondVariable, ~)
        out = firstVariable;
    end%

    function out = error_(~, ~, name)
        errorNames(1, end+1) = name; %#ok<AGROW>
        out = [];
    end%

    dispatch = struct( ...
        overlay=@overlay_, ...
        replace=@replace_, ...
        discard=@discard_, ...
        error=@error_ ...
    );
    strategyFunc = dispatch.(options.strategy);

    % numFirstPeriods = numel(firstSpan);
    % numSecondPeriods = numel(secondSpan);

    firstData = tablex.retrieveDataAsCellArray(firstTable, firstNames, mergedSpan, variant=":");
    secondData = tablex.retrieveDataAsCellArray(secondTable, secondNames, mergedSpan, variant=":");

    mergedData = cell(1, numel(mergedNames));

    for name = mergedNames
        nameInFirst = find(name == firstNames, 1);
        nameInSecond = find(name == secondNames, 1);
        nameInAll = find(name == mergedNames, 1);
        if ~isempty(nameInFirst) && isempty(nameInSecond)
            firstVariable = firstData{1, nameInFirst};
            mergedData{1, nameInAll} = firstVariable;
        elseif isempty(nameInFirst) && ~isempty(nameInSecond)
            secondVariable = secondData{1, nameInSecond};
            mergedData{1, nameInAll} = secondVariable;
        else
            firstVariable = firstData{1, nameInFirst};
            secondVariable = secondData{1, nameInSecond};
            mergedData{1, nameInAll} = strategyFunc(firstVariable, secondVariable, name);
        end
    end

    if ~isempty(errorNames)
        error( ...
            "Cannot merge timetables because the following variables exist in both timetables: %s." ...
            , join(errorNames, " ") ...
        );
    end

    outTable = tablex.fromCellArray(mergedData, mergedNames, mergedSpan);
    try
        higherDimNames = tablex.getHigherDims(firstTable);
        outTable = tablex.setHigherDims(outTable, higherDimNames);
    end

end%


function [mergedSpan, secondSpanIndex] = resolveSpans_(firstTable, secondTable)

    firstSpan = tablex.span(firstTable);
    secondSpan = tablex.span(secondTable);
    fh = datex.Backend.getFrequencyHandlerFromDatetime(firstSpan(1));

    firstStartPeriod = firstSpan(1);
    secondStartPeriod = secondSpan(1);

    firstEndPeriod = firstSpan(end);
    secondEndPeriod = secondSpan(end);

    firstSpan = datex.span(firstStartPeriod, firstEndPeriod);

    if firstStartPeriod < secondStartPeriod
        allStartPeriod = firstStartPeriod;
    else
        allStartPeriod = secondStartPeriod;
    end

    if firstEndPeriod > secondEndPeriod
        allEndPeriod = firstEndPeriod;
    else
        allEndPeriod = secondEndPeriod;
    end

    mergedSpan = datex.span(allStartPeriod, allEndPeriod);

    secondStartIndex = datex.diff(secondStartPeriod, allStartPeriod) + 1;
    secondEndIndex = datex.diff(secondEndPeriod, allStartPeriod) + 1;
    secondSpanIndex = secondStartIndex : secondEndIndex;

end%

