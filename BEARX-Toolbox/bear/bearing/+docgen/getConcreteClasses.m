
function [qualifiedNames, shortNames] = getConcreteClasses(module)

    folder = docgen.getTracerFolder(module);
    folderContents = what(folder);

    qualifiedNames = string.empty(1, 0);
    shortNames = string.empty(1, 0);
    for n = reshape(string(folderContents.m), 1, [])
        shortName = extractBefore(n, ".m");
        qualifiedName = module + "." + shortName;
        mc = docgen.getMetaclassFromQualifiedName(qualifiedName);
        if isempty(mc)
            continue
        end
        if mc.Abstract
            continue
        end
        shortNames(end+1) = shortName; %#ok<AGROW>
        qualifiedNames(end+1) = qualifiedName; %#ok<AGROW>
    end

end%

