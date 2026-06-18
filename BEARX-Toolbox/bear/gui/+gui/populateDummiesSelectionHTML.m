
function targetFile = populateDummiesSelectionHTML()

    SELECTION_FORM_PATH = {"dummies", "selection"};
    CALLBACK_ACTION = "gui_collectDummiesSelection";
    TARGET_PATH = fullfile(".", "html", "dummies", "selection.html");

    function updateForm_(htmlForm)
        gui.updateFormWithinCustomHTML(TARGET_PATH, htmlForm);
    end%

    currentModule = gui.getCurrentModule();
    if currentModule == ""
        htmlForm = "<p>You need to choose a reduced-form estimator first to see a selection form</p>";
        updateForm_(htmlForm);
        return
    end

    estimatorObj = gui.getCurrentEstimatorObj();
    canHaveDummies = isequal(estimatorObj.CanHaveDummies, true);
    if ~canHaveDummies
        htmlForm = "<p>The selected reduced-form estimator does not support dummy variables</p>";
        updateForm_(htmlForm);
        return
    end

    jsonForm = gui.readFormsFile(SELECTION_FORM_PATH);
    currentSelection = gui.querySelection(form=jsonForm);

    htmlForm = gui.generateFlatButtons( ...
        jsonForm ...
        , currentSelection ...
        , CALLBACK_ACTION...
        , type="checkbox" ...
    );

    updateForm_(htmlForm);

end%

