%{
%
% tablex.clip  Clip a timetable to a new span
%
%}

function tt = clip(tt, newStartPeriod, newEndPeriod)

    numPeriods = height(tt);
    if numPeriods == 0
        return
    end

    [newStartPosition, newEndPosition] ...
        = tablex.resolveNewStartEndPositions(tt, newStartPeriod, newEndPeriod);

    if newStartPosition > numPeriods || newEndPosition < 1
        tt = tt([], :)
        return
    end

    if newStartPosition < 1
        newStartPosition = 1;
    end

    if newEndPosition > numPeriods
        newEndPosition = numPeriods;
    end

    tt = tt(newStartPosition:newEndPosition, :);

end%

