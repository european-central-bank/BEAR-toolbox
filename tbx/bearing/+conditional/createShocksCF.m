
function shocksCF = createShocksCF(meta, planTbx, fcastSpan)

    if isempty(planTbx)
        shocksCF = [];
        return
    end

    planArray = planTbx{fcastSpan, meta.PseudoEndogenousNames};
    shocksCF = cell(size(planArray));
    dict = textual.createDictionary(meta.ShockNames);

    inxEmpty = cellfun(@isempty, planArray);
    for i = reshape(find(~inxEmpty), 1, [])
        shockNames = extractNames(planArray(i));
        shocksCF{i} = nan(size(shockNames));
        for j = 1 : numel(shockNames)
            shocksCF{i}(j) = dict.(shockNames(j));
        end
    end

end%


function names = extractNames(something)
    %[
    names = textual.stringify(something);
    names = join(names, " ");
    names = regexp(names, "\w+", "match");
    names = unique(names, "stable");
    %]
end%

