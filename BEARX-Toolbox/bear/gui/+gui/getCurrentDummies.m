
function dummies = getCurrentDummies()

    FORM_PATH = {"dummies", "selection"};
    selectionForm = gui.readFormsFile(FORM_PATH);
    dummies = gui.querySelection(form=selectionForm);

end%

