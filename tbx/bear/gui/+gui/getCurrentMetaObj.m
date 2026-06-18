
function metaObj = getCurrentMetaObj()

    currentModule = gui.getCurrentModule();
    metaSettings = gui.getCurrentMetaSettings();

    metaObj = eval(currentModule + ".Meta()");
    [~, cellValues] = gui.extractValuesFromForm(metaSettings);
    metaObj.update(cellValues{:});

end%

