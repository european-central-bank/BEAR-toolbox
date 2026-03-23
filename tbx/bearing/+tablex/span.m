
function out = span(inTable)

    arguments
        inTable timetable
    end

    startPeriod = tablex.startPeriod(inTable);
    endPeriod = tablex.endPeriod(inTable);
    out = datex.span(startPeriod, endPeriod);

end%

