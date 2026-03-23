
function prerequisites = getCurrentPrerequisites()

    FORM_PATH = {"tasks", "prerequisites"};
    prerequisites = gui.readFormsFile(FORM_PATH);

end%

