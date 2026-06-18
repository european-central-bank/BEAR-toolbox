
function unitData = extractUnit(data, index, dim)

    arguments
        data
        index (1, 1) double
        dim (1, 1) double = 3
    end

    if iscell(data)
        unitData = extractUnitFromCellArray(data, index, dim);
    else
        unitData = extractUnitFromNumericArray(data, index, dim);
    end

end%

