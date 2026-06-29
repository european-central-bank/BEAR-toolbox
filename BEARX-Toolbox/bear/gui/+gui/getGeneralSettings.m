
function general = getGeneralSettings()

    FORM_PATH = {"tasks", "general"};
    general = gui.readFormsFile(FORM_PATH);

end%

