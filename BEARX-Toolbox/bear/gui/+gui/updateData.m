
function obj = updateData(obj, update)

    arguments
        obj (1, 1) struct
        update (1, 1) struct
    end

    for n = textual.fields(update)
        if isfield(obj, n)
            obj.(n).value = update.(n);
        end
    end

end%
