
function scriptSettings = getCurrentScriptSettings()

    FORM_PATH = {"script", "settings"};
    scriptSettingsForm = gui.readFormsFile(FORM_PATH);
    scriptSettings = gui.extractValuesFromForm(scriptSettingsForm);

end%

