
function tt = fromCellArray(dataCell, names, rows)

    arguments
        dataCell (:, :) cell
        names (1, :) string
        rows (:, 1)
    end

    tt = timetable(dataCell{:}, rowTimes=rows, variableNames=names);

end%

