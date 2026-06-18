
function nameIndex = resolveNameIndex(names, nameIndex)

    arguments
        names (1, :) string
        nameIndex (1, :)
    end

    numNames = numel(names);

    if isequal(nameIndex, Inf)
        nameIndex = 1 : numNames;
        return
    end

    if isnumeric(nameIndex)
        if ~all(ismember(nameIndex, 1 : numNames))
            error("Invalid name index");
        end
        return
    end

    if isstring(nameIndex) || ischar(nameIndex)
        [~, nameIndex] = ismember(nameIndex, names);
        if any(nameIndex == 0)
            error("Invalid name index");
        end
        return
    end

end%

