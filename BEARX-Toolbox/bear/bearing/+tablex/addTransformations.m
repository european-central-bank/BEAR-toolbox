
function tt = addTransformations(tt, transformations)

    arguments
        tt timetable
        transformations (1, :) string
    end

    dispatcher = struct( ...
        "log", @log_ ...
        , "diff", @diff_ ...
        , "difflog", @difflog_ ...
        , "pct", @pct_ ...
    );

    transformations = strip(transformations);
    transformations = expandWildcard_(tt, transformations);

    numTransformations = numel(transformations);
    newData = cell(1, numTransformations);
    for i = 1 : numTransformations
        transformation = transformations(i);
        prefix = extractBefore(transformation, "_");
        name = extractAfter(transformation, "_");
        func = dispatcher.(prefix);
        data = tt.(name);
        newData{i} = func(data);
    end
    tt = addvars(tt, newData{:}, newVariableNames=transformations);

end%


function transformations = expandWildcard_(tt, transformations)
    names = tablex.names(tt);
    while true
        index = find(endsWith(transformations, "_*"), 1);
        if isempty(index)
            break
        end
        prefix = extractBefore(transformations(index), "_*");
        transformations = [ ...
            transformations(1:index-1), ...
            prefix + "_" + names, ...
            transformations(index+1:end) ...
        ];
    end
end%


function data = log_(data)
    data = log(data);
end%


function data = temporal_(data, func, k)
    shape = size(data);
    data = func(data(k+1:end, :), data(1:end-k, :));
    data = reshape(data, [shape(1)-k, shape(2:end)]);
    prepend = nan([1, shape(2:end)]);
    data = [ prepend; data ];
end%


function data = diff_(data)
    data = temporal_(data, @minus, 1);
end%


function data = difflog_(data)
    data = temporal_(data, @(x, y) log(x)-log(y), 1);
end%


function data = pct_(data)
    data = temporal_(data, @(x, y) 100*(x - y)./y, 1);
end%

