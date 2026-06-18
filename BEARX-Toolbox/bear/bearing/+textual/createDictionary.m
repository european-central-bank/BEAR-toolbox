
function dict = createDictionary(list, dict)

    arguments
        list (1, :) string
        dict (1, 1) struct = struct()
    end

    if isempty(list) || isequal(list, [""])
        return
    end

    for i = 1 : numel(list)
        dict.(list(i)) = i;
    end

end%

