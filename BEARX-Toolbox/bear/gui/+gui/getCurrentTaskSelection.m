
function taskSelection = getCurrentTaskSelection()

    FORM_PATH = {"tasks", "selection"};
    taskSelection = gui.readFormsFile(FORM_PATH);
    taskSelection = gui.extractValuesFromForm(taskSelection);

end%

