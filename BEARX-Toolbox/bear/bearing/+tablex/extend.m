%{
%
% tablex.clip  Clip a timetable to a new span
%
%}

function newTbl = extend(tbl, newStartPeriod, newEndPeriod)

    startPeriod = tbl.Time(1);
    endPeriod = tbl.Time(end);

    if isequal(newStartPeriod, -Inf)
        newStartPeriod = startPeriod;
    end

    if isequal(newEndPeriod, Inf)
        newEndPeriod = endPeriod;
    end

    numPrepend = datex.diff(startPeriod, newStartPeriod);
    numAppend = max(0, datex.diff(newEndPeriod, endPeriod));

    names = tablex.names(tbl);
    span = tablex.span(tbl);
    newSpan = datex.span(newStartPeriod, newEndPeriod);

    newData = tablex.retrieveDataAsCellArray(tbl, names, newSpan, variant=':');
    newTbl = tablex.fromCellArray(newData, names, newSpan);

end%

