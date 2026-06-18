
function tasks = getCurrentTasks()

    FORM_PATH = {"tasks", "selection"};
    selectionForm = gui.readFormsFile(FORM_PATH);
    tasks = gui.querySelection(form=selectionForm);

end%

