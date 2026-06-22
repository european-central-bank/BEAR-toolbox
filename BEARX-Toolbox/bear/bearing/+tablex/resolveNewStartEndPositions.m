
function [newStartPosition, newEndPosition] = resolveNewStartEndPositions(tt, newStartPeriod, newEndPeriod)

    numPeriods = height(tt);
    startPeriod = tablex.startPeriod(tt);
    endPeriod = tablex.endPeriod(tt);

    if isinf(newStartPeriod)
        newStartPosition = 1;
    else
        newStartPosition = datex.diff(newStartPeriod, startPeriod) + 1;
    end

    if isinf(newEndPeriod)
        newEndPosition = numPeriods;
    else
        newEndPosition = datex.diff(newEndPeriod, startPeriod) + 1;
    end

end%

