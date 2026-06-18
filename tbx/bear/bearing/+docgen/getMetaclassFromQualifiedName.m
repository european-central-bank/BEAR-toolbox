
function mc = getMetaclassFromQualifiedName(qualifiedName)

    try
        mc = eval("?" + qualifiedName);
    catch
        mc = [];
    end

end%

