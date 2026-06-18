
function table = setHigherDims(table, higherDimNames)

    arguments
        table timetable
        higherDimNames (1, :) cell
    end

    try
        table = addprop(table, "HigherDims", "table");
    end
    table.Properties.CustomProperties.HigherDims = higherDimNames;

end%

