
function targetFile = populateEstimatorSelectionHTML()

    FORM_PATH = {"estimation", "selection"};
    CALLBACK_ACTION = "gui_collectEstimatorSelection";
    HTML_END_PATH = {"html", "estimation", "selection.html"};
    NO_SELECTION = "[No estimator selected]";

    jsonForm = gui.readFormsFile(FORM_PATH);
    currentEstimator = gui.getCurrentEstimator();

    categories = gui.readFormsFile({"estimation", "categories"});
    htmlForm = gui.generateCategorizedButtons( ...
        jsonForm ...
        , currentEstimator ...
        , categories ...
        , CALLBACK_ACTION...
    );

    if currentEstimator ~= ""
        currentSelection = currentEstimator;
        currentSelectionLabel = jsonForm.(currentSelection).label;
    else
        currentSelection = NO_SELECTION;
        currentSelectionLabel = "No estimator selected";
    end

    targetPath = fullfile(".", HTML_END_PATH{:});
    gui.updateFormWithinCustomHTML(targetPath, htmlForm);
    gui.updateCurrentSelectionWithinCustomHTML(targetPath, currentSelectionLabel);

end%

