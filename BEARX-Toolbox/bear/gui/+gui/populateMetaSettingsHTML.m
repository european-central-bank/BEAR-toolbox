
function targetPath = populateMetaSettingsHTML()

    NO_ESTIMATOR_TEXT = "<p>You need to choose a reduced-form estimator first</p>";
    CALLBACK_ACTION = "gui_collectMetaSettings";
    TARGET_PATH = fullfile(".", "html", "meta", "settings.html");

    metaSettings = gui.getCurrentMetaSettings();
    if ~isempty(metaSettings)
        htmlForm = gui.generateFreeForm(metaSettings, action=CALLBACK_ACTION);
    else
        htmlForm = NO_ESTIMATOR_TEXT;
    end

    gui.updateFormWithinCustomHTML(TARGET_PATH, htmlForm);

end%

