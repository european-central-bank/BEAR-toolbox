
function shocksCF = createShocksCF(meta, planTbx, fcastSpan)

    if isempty(planTbx)
        shocksCF = [];
        return
    end

    planArray = planTbx{fcastSpan, meta.PseudoEndogenousNames};
    shocksCF = cell(size(planArray));
    % BEAR6-FIX: tutorials use two valid naming conventions for plan shocks:
    %   - prefixed global names ("US_DEM","EA_DEM",...) -> match meta.ShockNames
    %   - unprefixed concepts   ("DEM","SUP","POL")     -> match meta.ShockConcepts
    % We normalize both to GLOBAL indices over meta.ShockNames so that the
    % downstream subtraction (j-1)*NumShockConcepts in +base/@Structural and
    % +model/@Structural maps them to per-unit indices [1..NumShockConcepts].
    % For unprefixed concept names we infer the unit from the column of
    % planArray: PseudoEndogenousNames are grouped by unit, NumEndogenousConcepts
    % columns per unit.
    globalDict  = textual.createDictionary(meta.ShockNames);
    conceptDict = textual.createDictionary(meta.ShockConcepts);
    numShockConcepts    = meta.NumShockConcepts;
    numEndogenousConcepts = meta.NumEndogenousConcepts;

    inxEmpty = cellfun(@isempty, planArray);
    for i = reshape(find(~inxEmpty), 1, [])
        [~, col] = ind2sub(size(planArray), i);
        unit = ceil(col / numEndogenousConcepts);
        shockNames = extractNames(planArray(i));
        shocksCF{i} = nan(size(shockNames));
        for j = 1 : numel(shockNames)
            name = shockNames(j);
            if isfield(globalDict, name)
                shocksCF{i}(j) = globalDict.(name);
            elseif isfield(conceptDict, name)
                shocksCF{i}(j) = (unit-1)*numShockConcepts + conceptDict.(name);
            else
                error("conditional:createShocksCF:UnknownShock", ...
                    "Unknown shock name '%s' in conditional forecast plan.", name);
            end
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

