
function updateInstantZerosTable()

    FORM_PATH = {"identification", "InstantZeros"};
    TITLE = "Instant exact zero restrictions";

    form = gui.readFormsFile(FORM_PATH);
    meta = gui.getCurrentMetaObj();
    endogenousNames = meta.SeparableEndogenousNames;
    shockNames = meta.SeparableShockNames;

    gui.updateTableWhenNecessary( ...
        rowNames=endogenousNames, ...
        columnNames=shockNames, ...
        fileName=string(form.FileName.value), ...
        title=TITLE ...
    );

end%

