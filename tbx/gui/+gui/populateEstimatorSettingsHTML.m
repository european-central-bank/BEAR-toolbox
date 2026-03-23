
function targetPath = populateEstimatorSettingsHTML()

    NO_SELECTION_TEXT = "<p>Select an estimator first to edit its settings</p>";
    CALLBACK_ACTION = "gui_collectEstimatorSettings";
    TARGET_PATH = fullfile(".", "html", "estimation", "settings.html");

    estimator = gui.getCurrentEstimator();
    if estimator ~= ""
        estimatorSettings = gui.getCurrentEstimatorSettings();
        htmlForm = gui.generateFreeForm( ...
            estimatorSettings ...
            , header=estimator ...
            , action=CALLBACK_ACTION ...
            , getFields = @(x) sort(textual.fields(x)) ...
        );
    else
        htmlForm = NO_SELECTION_TEXT;
    end

    gui.updateFormWithinCustomHTML(TARGET_PATH, htmlForm);

end%

