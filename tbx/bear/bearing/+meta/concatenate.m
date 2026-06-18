

function fullNames = concatenate(prefix, names)

    arguments
        prefix (1, 1) string
        names (1, :) string
    end

    SEPARATOR = "_";

    if prefix == ""
        fullNames = names;
        return
    end

    fullNames = prefix + SEPARATOR + names;

end%

