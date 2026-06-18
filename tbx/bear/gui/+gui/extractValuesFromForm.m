
function [structValues, cellValues]  = extractValuesFromForm(settings)

    structValues = struct();
    cellValues = {};
    for key = textual.fields(settings)
        value = settings.(key).value;
        structValues.(key) = value;
        cellValues = [cellValues, {key, value}];
    end

end%

