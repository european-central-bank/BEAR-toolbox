
function targetFile = populateIdentificationSelectionHTML()

    SELECTION_FORM_PATH = {"identification", "selection"};
    CALLBACK_ACTION = "gui_collectIdentificationSelection";
    HTML_END_PATH = {"html", "identification", "selection.html"};

    NO_ESTIMATOR_FORM = "<p>You need to choose a reduced-form estimator first</p>";
    CANNOT_IDENTIFY_FORM = "<p>The selected reduced-form estimator does not support structural identification</p>";
    NO_SELECTION_TEXT = "[No identification scheme selected]";

    targetPath = fullfile(".", HTML_END_PATH{:});

    function updateCustomHTML_(htmlForm, currentSelectionLabel)
        gui.updateFormWithinCustomHTML(targetPath, htmlForm);
        gui.updateCurrentSelectionWithinCustomHTML(targetPath, currentSelectionLabel);
    end%

    if gui.getCurrentModule() == ""
        updateCustomHTML_(NO_ESTIMATOR_FORM, NO_SELECTION_TEXT);
        return
    end

    if ~gui.canBeIdentified()
        updateCustomHTML_(CANNOT_IDENTIFY_FORM, NO_SELECTION_TEXT);
        return
    end

    jsonForm = gui.readFormsFile(SELECTION_FORM_PATH);
    currentSelection = gui.querySelection(form=jsonForm, count=[0, 1]);
    currentSelectionLabel = jsonForm.(currentSelection).label;

    htmlForm = gui.generateFlatButtons( ...
        jsonForm ...
        , currentSelection ...
        , CALLBACK_ACTION...
    );
    updateCustomHTML_(htmlForm, currentSelectionLabel);

end%

