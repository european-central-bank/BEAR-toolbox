
function periods = resolvePeriods(inTable, periods, options)

    arguments
        inTable timetable
        periods (1, :) datetime
        options.Shift (1, 1) double = 0
    end

    if options.Shift ~= 0
        periods = datex.shift(periods, options.Shift);
    end

end%

