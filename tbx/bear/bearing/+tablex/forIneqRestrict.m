
function tbx = forIneqRestrict(model)

    meta = model.getMeta();
    separableEndogenousNames = meta.SeparableEndogenousNames;
    separableShockNames = meta.SeparableShockNames;

    data = repmat({repmat("", meta.NumEndogenousNames, 1)}, 1, meta.NumShockNames);

    tbx = table( ...
        data{:}, ...
        rowNames=separableEndogenousNames, ...
        variableNames=separableShockNames ...
    );

end%


