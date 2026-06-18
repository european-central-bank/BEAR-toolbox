
function updateLongRunDummiesTable()

    FORM_PATH = {"dummies", "LongRun"};
    TITLE = "Dummy observations for long-run constraints";

    form = gui.readFormsFile(FORM_PATH);
    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.EndogenousNames;

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=endogenousNames, ...
        fileName=string(form.FileName.value), ...
        title=TITLE ...
    );

end%

