
function targetFile = populateScriptSettingsHTML()

    FORM_PATH = {"script", "settings"};
    CALLBACK_ACTION = "gui_collectScriptSettings";
    TARGET_PATH = fullfile(".", "html", "script", "execution.html");

    jsonForm = gui.readFormsFile(FORM_PATH);
    htmlForm = gui.generateFreeForm(jsonForm, action=CALLBACK_ACTION);
    gui.updateFormWithinCustomHTML(TARGET_PATH, htmlForm);

end%

