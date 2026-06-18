
function unitData = extractUnitFromNumericArray(data, index, dim)

    numUnits = size(data, dim);
    if numUnits == 1
        unitData = data;
        return
    end

    ndimsData = ndims(data);
    ref = repmat({':'}, 1, ndimsData);
    ref{dim} = index;
    unitData = data(ref{:});

end%

