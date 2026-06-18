
function metaSettings = getCurrentMetaSettings()

    module = gui.getCurrentModule();

    if module == ""
        metaSettings = [];
        return
    end

    path = {"meta", module};
    metaSettings = gui.readFormsFile(path);

end%

