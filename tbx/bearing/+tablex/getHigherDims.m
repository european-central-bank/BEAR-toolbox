
function higherDims = getHigherDims(table, dim)

    arguments
        table timetable
        dim (1, 1) double = NaN
    end

    higherDims = table.Properties.CustomProperties.HigherDims;

    if ~isnan(dim)
        higherDims = higherDims{dim-2};
    end


end%

