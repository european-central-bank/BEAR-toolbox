
function [tt, freq] = fromTable(plainTable, options)

    arguments
        plainTable table
        %
        options.TimeColumn (1, 1) string = "Time"
        options.Frequency (1, 1) double = NaN
        options.PeriodConstructor = @datex.fromSdmx
        options.Trim (1, 1) logical = true
    end

    if height(plainTable) == 0
        error("Cannot handle empty tables");
    end

    timeColumn = plainTable.(options.TimeColumn);
    if isstring(timeColumn) || iscellstr(timeColumn)
        timeColumn = options.PeriodConstructor(timeColumn);
    end

    if isequaln(options.Frequency, NaN)
        freq = datex.frequency(timeColumn(1));
        if isequaln(freq, NaN)
            error("Cannot determine time frequency of the time column");
        end
    else
        freq = options.Frequency;
    end

    plainTable = removevars(plainTable, options.TimeColumn);
    tt = table2timetable(plainTable, rowTimes=timeColumn);
    tt = tablex.reconcileTimetable(tt, frequency=freq, trim=options.Trim);

end%

