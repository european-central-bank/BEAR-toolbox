
function data = unflattenSeparableUnits(data, numSeparableUnits)

    if numSeparableUnits <= 1
        return
    end

    data = reshape(data, size(data, 1), [], numSeparableUnits);

end%

