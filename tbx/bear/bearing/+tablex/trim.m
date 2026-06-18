
function outTable = trim(inTable)

    arguments
        inTable timetable
    end

    periods = inTable.Time;
    dataArray = inTable{:, :};
    if ~isnumeric(dataArray)
        error("Input timetable must contain only numeric data");
    end

    inxNaN = all(isnan(dataArray), 2);
    if all(inxNaN)
        outTable = inTable([], :);
        return
    end

    firstAvail = find(~inxNaN, 1, "first");
    lastAvail = find(~inxNaN, 1, "last");
    outTable = inTable(firstAvail:lastAvail, :);

end%

