
function scriptName = getCurrentScriptName()

    FORM_PATH = {"script", "settings"};
    scriptSettings = gui.readFormsFile(FORM_PATH);

    value = scriptSettings.ScriptName.value;
    if isempty(value)
        scriptName = "";
        return
    end

    scriptName = string(value);

end%

